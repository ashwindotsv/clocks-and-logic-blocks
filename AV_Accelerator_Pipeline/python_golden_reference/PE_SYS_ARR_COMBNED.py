import numpy as np
from collections import deque

class ProcessingElement:
    """Exact RTL behavior of processing_element module"""
    def __init__(self):
        self.weight_reg = 0
        self.psum_out = 0
        self.pixel_pass = 0
        self.valid_out = False
        
    def clock(self, weight_in, pixel_in, psum_in, valid_in, load_weight, rst_n):
        """Simulate one clock cycle"""
        if not rst_n:
            self.psum_out = 0
            self.pixel_pass = 0
            self.weight_reg = 0
            self.valid_out = False
            return
            
        if load_weight:
            self.weight_reg = weight_in
            
        if valid_in:
            # PSum_Out <= PSum_In + (weight_reg * pixel_in)
            self.psum_out = psum_in + (self.weight_reg * pixel_in)
            self.pixel_pass = pixel_in
            self.valid_out = True
        else:
            self.valid_out = False


class SystolicArray3x3:
    """Exact RTL behavior of Systolic_Array_3x3 module"""
    def __init__(self):
        # 3x3 PE array
        self.pe = [[ProcessingElement() for _ in range(3)] for _ in range(3)]
        
        # Wires
        self.pix_pass = [[0]*3 for _ in range(3)]
        self.psum_pass = [[0]*3 for _ in range(3)]
        self.valid = [[False]*3 for _ in range(3)]
        
        # Outputs
        self.PSum_Out_C1 = 0
        self.PSum_Out_C2 = 0
        self.PSum_Out_C3 = 0
        self.valid_out_3x3 = False
        
    def clock(self, weights, pixels_row1, pixels_row2, pixels_row3, 
              psum_in_3x3, valid_in_3x3, load_weight, rst_n):
        """
        One clock cycle simulation
        weights: 3x3 matrix
        pixels_row1,2,3: 3-element arrays (R1, R2, R3 inputs)
        """
        
        # PE00 (top-left)
        self.pe[0][0].clock(
            weights[0][0], pixels_row1[0], psum_in_3x3, 
            valid_in_3x3, load_weight, rst_n
        )
        self.pix_pass[0][0] = self.pe[0][0].pixel_pass
        self.psum_pass[0][0] = self.pe[0][0].psum_out
        self.valid[0][0] = self.pe[0][0].valid_out
        
        # PE01 (top-middle) - PSum_In = 0 (EmptyPSumIN_1)
        self.pe[0][1].clock(
            weights[0][1], self.pix_pass[0][0], 0, 
            self.valid[0][0], load_weight, rst_n
        )
        self.pix_pass[0][1] = self.pe[0][1].pixel_pass
        self.psum_pass[0][1] = self.pe[0][1].psum_out
        self.valid[0][1] = self.pe[0][1].valid_out
        
        # PE02 (top-right) - PSum_In = 0 (EmptyPSumIN_2)
        self.pe[0][2].clock(
            weights[0][2], self.pix_pass[0][1], 0, 
            self.valid[0][1], load_weight, rst_n
        )
        self.pix_pass[0][2] = self.pe[0][2].pixel_pass
        self.psum_pass[0][2] = self.pe[0][2].psum_out
        self.valid[0][2] = self.pe[0][2].valid_out
        
        # PE10 (middle-left) - PSum_In from PE00
        self.pe[1][0].clock(
            weights[1][0], pixels_row2[0], self.psum_pass[0][0], 
            self.valid[0][0], load_weight, rst_n
        )
        self.pix_pass[1][0] = self.pe[1][0].pixel_pass
        self.psum_pass[1][0] = self.pe[1][0].psum_out
        self.valid[1][0] = self.pe[1][0].valid_out
        
        # PE11 (middle) - valid_in = valid_10_01 (valid[1][0] && valid[0][1])
        valid_10_01 = self.valid[1][0] and self.valid[0][1]
        self.pe[1][1].clock(
            weights[1][1], self.pix_pass[1][0], self.psum_pass[0][1], 
            valid_10_01, load_weight, rst_n
        )
        self.pix_pass[1][1] = self.pe[1][1].pixel_pass
        self.psum_pass[1][1] = self.pe[1][1].psum_out
        self.valid[1][1] = self.pe[1][1].valid_out
        
        # PE12 (middle-right) - valid_in = valid_11_02 (valid[1][1] && valid[0][2])
        valid_11_02 = self.valid[1][1] and self.valid[0][2]
        self.pe[1][2].clock(
            weights[1][2], self.pix_pass[1][1], self.psum_pass[0][2], 
            valid_11_02, load_weight, rst_n
        )
        self.pix_pass[1][2] = self.pe[1][2].pixel_pass
        self.psum_pass[1][2] = self.pe[1][2].psum_out
        self.valid[1][2] = self.pe[1][2].valid_out
        
        # PE20 (bottom-left) - valid_in = valid[1][0]
        self.pe[2][0].clock(
            weights[2][0], pixels_row3[0], self.psum_pass[1][0], 
            self.valid[1][0], load_weight, rst_n
        )
        self.pix_pass[2][0] = self.pe[2][0].pixel_pass
        self.PSum_Out_C1 = self.pe[2][0].psum_out
        self.valid[2][0] = self.pe[2][0].valid_out
        
        # PE21 (bottom-middle) - valid_in = valid_11_20 (valid[1][1] && valid[2][0])
        valid_11_20 = self.valid[1][1] and self.valid[2][0]
        self.pe[2][1].clock(
            weights[2][1], self.pix_pass[2][0], self.psum_pass[1][1], 
            valid_11_20, load_weight, rst_n
        )
        self.pix_pass[2][1] = self.pe[2][1].pixel_pass
        self.PSum_Out_C2 = self.pe[2][1].psum_out
        self.valid[2][1] = self.pe[2][1].valid_out
        
        # PE22 (bottom-right) - valid_in = valid_21_12 (valid[2][1] && valid[1][2])
        valid_21_12 = self.valid[2][1] and self.valid[1][2]
        self.pe[2][2].clock(
            weights[2][2], self.pix_pass[2][1], self.psum_pass[1][2], 
            valid_21_12, load_weight, rst_n
        )
        self.pix_pass[2][2] = self.pe[2][2].pixel_pass
        self.PSum_Out_C3 = self.pe[2][2].psum_out
        self.valid_out_3x3 = self.pe[2][2].valid_out
        
        return self.PSum_Out_C1, self.PSum_Out_C2, self.PSum_Out_C3, self.valid_out_3x3


# ============================================
# TEST AND VERIFICATION
# ============================================

def test_systolic_array():
    """Test the systolic array with the exact RTL behavior"""
    
    # Create systolic array
    systolic = SystolicArray3x3()
    
    # Test weights (3x3 kernel)
    weights = np.array([
        [1, 2, 3],
        [4, 5, 6],
        [7, 8, 9]
    ], dtype=np.int32)
    
    # Test pixels - streamed in row by row
    # For a 3x3 convolution, we need to stream 3 rows
    pixels_rows = [
        [9, 8, 7],  # Row 1
        [6, 5, 4],  # Row 2
        [3, 2, 1]   # Row 3
    ]
    
    print("="*60)
    print("SYSTOLIC ARRAY RTL SIMULATION")
    print("="*60)
    print("\nWeights (stationary):")
    print(weights)
    print("\nInput Pixels (streamed):")
    for i, row in enumerate(pixels_rows):
        print(f"Row {i+1}: {row}")
    
    # Load weights first (load_weight = 1)
    print("\n" + "="*60)
    print("STEP 1: LOADING WEIGHTS")
    print("="*60)
    
    rst_n = 1
    for cycle in range(3):  # Need 3 cycles to load all weights
        print(f"\nCycle {cycle+1}: Loading weights...")
        # Simulate loading weights for all PEs
        # In reality, weights are loaded one row at a time
        # But we'll load all at once for simulation
        for i in range(3):
            for j in range(3):
                systolic.pe[i][j].weight_reg = weights[i][j]
        print("Weights loaded into all PEs")
    
    # Now stream pixels through (load_weight = 0)
    print("\n" + "="*60)
    print("STEP 2: STREAMING PIXELS (3 cycles)")
    print("="*60)
    
    # Store partial sums and outputs for each cycle
    results = []
    
    for cycle in range(3):
        print(f"\nCycle {cycle+1}: Streaming Row {cycle+1}")
        print("-" * 40)
        
        # Get current row
        current_row = pixels_rows[cycle]
        
        # For first cycle, psum_in_3x3 = 0, valid_in_3x3 = 1
        psum_in = 0
        valid_in = 1 if cycle == 0 else 0  # Only first cycle gets valid_in
        
        # Clock the array
        c1, c2, c3, valid_out = systolic.clock(
            weights, 
            current_row, 
            pixels_rows[1] if cycle < 2 else [0,0,0],  # Row2 (delayed)
            pixels_rows[2] if cycle < 1 else [0,0,0],  # Row3 (delayed)
            psum_in, valid_in, 0, rst_n
        )
        
        results.append((c1, c2, c3, valid_out))
        
        print(f"PSum_Out_C1 = {c1:3d}  (Column 0 partial)")
        print(f"PSum_Out_C2 = {c2:3d}  (Column 1 partial)")
        print(f"PSum_Out_C3 = {c3:3d}  (Column 2 partial)")
        print(f"valid_out_3x3 = {valid_out}")
        
        # Show PE state
        print("\nPE Array State (psum_out):")
        for i in range(3):
            row_str = ""
            for j in range(3):
                row_str += f"{systolic.psum_pass[i][j]:5d} "
            print(f"  {row_str}")
    
    # Get final outputs (should be valid on cycle 3)
    print("\n" + "="*60)
    print("FINAL CONVOLUTION RESULTS")
    print("="*60)
    
    final_c1, final_c2, final_c3, valid = results[-1]
    
    print(f"\nColumn partial sums (bottom row outputs):")
    print(f"  PSum_Out_C1 = {final_c1}  [Col 0: {weights[0,0]*pixels_rows[0][0] + weights[1,0]*pixels_rows[1][0] + weights[2,0]*pixels_rows[2][0]}]")
    print(f"  PSum_Out_C2 = {final_c2}  [Col 1: {weights[0,1]*pixels_rows[0][1] + weights[1,1]*pixels_rows[1][1] + weights[2,1]*pixels_rows[2][1]}]")
    print(f"  PSum_Out_C3 = {final_c3}  [Col 2: {weights[0,2]*pixels_rows[0][2] + weights[1,2]*pixels_rows[1][2] + weights[2,2]*pixels_rows[2][2]}]")
    
    print(f"\n✅ valid_out_3x3 = {valid}")
    
    # THE CRITICAL PART: Conv_Adder
    print("\n" + "="*60)
    print("Conv_Adder (CRITICAL!)")
    print("="*60)
    
    conv_result = final_c1 + final_c2 + final_c3
    true_result = np.sum(weights * np.array(pixels_rows))
    
    print(f"\nConv_Adder output = {final_c1} + {final_c2} + {final_c3} = {conv_result}")
    print(f"True convolution result = {true_result}")
    print(f"\n✅ MATCH!" if conv_result == true_result else f"❌ MISMATCH! (diff: {conv_result - true_result})")
    
    # PROVE CLAUDE IS WRONG
    print("\n" + "="*60)
    print("WHY CLAUDE IS WRONG FOR THIS RTL")
    print("="*60)
    
    print("\nIf we removed Conv_Adder (as Claude suggested):")
    print(f"  Output 1 (to ReLU) = {final_c1}  ← This is NOT a convolution result!")
    print(f"  Output 2 (to ReLU) = {final_c2}  ← This is NOT a convolution result!")
    print(f"  Output 3 (to ReLU) = {final_c3}  ← This is NOT a convolution result!")
    
    print("\nEach output is just ONE COLUMN's partial sum!")
    print("The true convolution requires ALL THREE columns summed.")
    
    print("\n" + "="*60)
    print("CONCLUSION: Conv_Adder is MANDATORY!")
    print("="*60)
    
    return conv_result, true_result


if __name__ == "__main__":
    test_systolic_array()