#!/usr/bin/env python3
"""
UART Transmitter and Receiver Model
Fixed version with proper waveform handling
"""

import time
from dataclasses import dataclass
from typing import Optional, List, Tuple

@dataclass
class UARTConfig:
    """UART configuration parameters"""
    baud_rate: int = 115200
    data_bits: int = 8
    stop_bits: int = 1
    parity: Optional[str] = None  # 'even', 'odd', or None
    samples_per_bit: int = 16     # Oversampling factor for Rx


class UARTTx:
    """UART Transmitter Model"""
    
    def __init__(self, config: UARTConfig = UARTConfig()):
        self.config = config
        self.busy = False
        self.bit_time = 1.0 / config.baud_rate
        self.tx_pin = 1  # Idle state is high
        
    def send_byte(self, data: int, verbose: bool = False) -> List[int]:
        """
        Simulate transmitting a byte
        Returns the complete frame bits
        """
        frame = []
        
        # Start bit (always 0)
        frame.append(0)
        if verbose:
            print(f"Start bit: 0")
        
        # Data bits (LSB first)
        for i in range(self.config.data_bits):
            bit = (data >> i) & 1
            frame.append(bit)
            if verbose:
                print(f"Data bit {i}: {bit}")
        
        # Parity bit (if enabled)
        if self.config.parity:
            parity = self._calculate_parity(data)
            frame.append(parity)
            if verbose:
                print(f"Parity bit: {parity}")
        
        # Stop bit(s) (always 1)
        for i in range(self.config.stop_bits):
            frame.append(1)
            if verbose:
                print(f"Stop bit {i+1}: 1")
        
        return frame
    
    def generate_waveform(self, data: int, samples_per_bit: int = None) -> List[int]:
        """
        Generate a sampled waveform for the transmission
        """
        if samples_per_bit is None:
            samples_per_bit = self.config.samples_per_bit
            
        bits = self.send_byte(data)
        waveform = []
        
        for bit in bits:
            waveform.extend([bit] * samples_per_bit)
        
        # Add some idle time after transmission (2 bit periods)
        waveform.extend([1] * (samples_per_bit * 2))
        
        return waveform
    
    def _calculate_parity(self, data: int) -> int:
        """Calculate parity bit"""
        ones = bin(data).count('1')
        if self.config.parity == 'even':
            return 0 if ones % 2 == 0 else 1
        elif self.config.parity == 'odd':
            return 1 if ones % 2 == 0 else 0
        return 0
    
    def get_frame_length(self) -> int:
        """Return total frame length in bits"""
        length = 1 + self.config.data_bits  # Start + Data
        if self.config.parity:
            length += 1
        length += self.config.stop_bits
        return length
    
    def get_frame_bits_string(self, data: int) -> str:
        """Get formatted frame bits as string for visualization"""
        bits = self.send_byte(data)
        frame_str = ""
        for i, bit in enumerate(bits):
            if i == 0:
                frame_str += f"[Start:{bit}]"
            elif i < 1 + self.config.data_bits:
                frame_str += f"[D{i-1}:{bit}]"
            elif self.config.parity and i == 1 + self.config.data_bits:
                frame_str += f"[Parity:{bit}]"
            else:
                frame_str += f"[Stop:{bit}]"
        return frame_str


class UARTRx:
    """UART Receiver Model with proper oversampling"""
    
    def __init__(self, config: UARTConfig = UARTConfig()):
        self.config = config
        self.rx_pin = 1  # Idle state
        self.bit_time = 1.0 / config.baud_rate
        self.samples_per_bit = config.samples_per_bit
        
    def receive_byte(self, waveform: List[int], verbose: bool = False) -> Optional[int]:
        """
        Decode a UART frame from a sampled waveform
        """
        if len(waveform) < self.samples_per_bit * 2:  # Need at least 2 bits worth
            print(f"Waveform too short: {len(waveform)} samples")
            return None
        
        # Find the start bit (falling edge)
        start_index = self._find_start_bit(waveform)
        if start_index is None:
            if verbose:
                print("No start bit detected")
            return None
        
        if verbose:
            print(f"Start bit detected at sample {start_index}")
        
        # Calculate bit boundaries
        # Sample at the middle of each bit period
        bit_samples = []
        frame_length = self._get_frame_length()
        
        for i in range(frame_length):
            # Sample at midpoint of each bit period
            sample_pos = start_index + (i * self.samples_per_bit) + (self.samples_per_bit // 2)
            if sample_pos >= len(waveform):
                print(f"Sample {i} at position {sample_pos} beyond waveform length {len(waveform)}")
                return None
            
            bit = waveform[sample_pos]
            bit_samples.append(bit)
            
            if verbose:
                print(f"Bit {i}: sample at {sample_pos}, value = {bit}")
        
        # Decode the frame
        return self._decode_frame(bit_samples, verbose)
    
    def _find_start_bit(self, waveform: List[int]) -> Optional[int]:
        """Find the falling edge indicating start bit"""
        for i in range(len(waveform) - 1):
            if waveform[i] == 1 and waveform[i+1] == 0:
                # Make sure we have enough samples after this
                if len(waveform) - i >= self.samples_per_bit * 3:
                    return i + 1
        return None
    
    def _get_frame_length(self) -> int:
        """Calculate total frame length in bits"""
        length = 1 + self.config.data_bits  # Start + Data
        if self.config.parity:
            length += 1
        length += self.config.stop_bits
        return length
    
    def _decode_frame(self, bits: List[int], verbose: bool = False) -> Optional[int]:
        """
        Decode the frame bits back to data
        """
        expected_length = self._get_frame_length()
        
        if len(bits) < expected_length:
            print(f"Frame incomplete: got {len(bits)}, expected {expected_length}")
            return None
        
        # Check start bit
        if bits[0] != 0:
            print("Invalid start bit")
            return None
        
        # Extract data bits (bits 1 to data_bits)
        data = 0
        for i in range(self.config.data_bits):
            bit = bits[1 + i]
            data |= (bit << i)
            if verbose:
                print(f"Data bit {i}: {bit} -> value so far: 0x{data:02X}")
        
        # Check parity
        if self.config.parity:
            parity_idx = 1 + self.config.data_bits
            received_parity = bits[parity_idx]
            calculated_parity = self._calculate_parity(data)
            if received_parity != calculated_parity:
                print(f"Parity error! Received: {received_parity}, Calculated: {calculated_parity}")
                return None
        
        # Check stop bits
        stop_start = 1 + self.config.data_bits
        if self.config.parity:
            stop_start += 1
        
        for i in range(self.config.stop_bits):
            if bits[stop_start + i] != 1:
                print(f"Framing error at stop bit {i+1}")
                return None
        
        return data
    
    def _calculate_parity(self, data: int) -> int:
        ones = bin(data).count('1')
        if self.config.parity == 'even':
            return 0 if ones % 2 == 0 else 1
        elif self.config.parity == 'odd':
            return 1 if ones % 2 == 0 else 0
        return 0


class UARTLoopback:
    """Combine Tx and Rx for testing"""
    
    def __init__(self, config: UARTConfig = UARTConfig()):
        self.config = config
        self.tx = UARTTx(config)
        self.rx = UARTRx(config)
    
    def transmit_and_receive(self, data: int, verbose: bool = False) -> Tuple[Optional[int], List[int]]:
        """Send data, capture waveform, and receive it back"""
        # Generate waveform
        waveform = self.tx.generate_waveform(data, self.config.samples_per_bit)
        
        # Receive
        received = self.rx.receive_byte(waveform, verbose=verbose)
        
        return received, waveform


def test_uart_basic():
    """Basic loopback test"""
    print("\n" + "="*60)
    print("Test 1: Basic Loopback Tests")
    print("="*60)
    
    config = UARTConfig(baud_rate=115200, data_bits=8, stop_bits=1)
    loopback = UARTLoopback(config)
    
    test_data = [0x55, 0xAA, 0x00, 0xFF, 0x7E, 0x81, 0x01, 0xFE, 0x42, 0x3C]
    
    passed = 0
    failed = 0
    
    for data in test_data:
        result, _ = loopback.transmit_and_receive(data)
        status = "✓ PASS" if result == data else "✗ FAIL"
        if result == data:
            passed += 1
        else:
            failed += 1
            if result is None:
                print(f"Sent: 0x{data:02X}, Received: None -> {status}")
            else:
                print(f"Sent: 0x{data:02X}, Received: 0x{result:02X} -> {status}")
    
    print(f"\nResults: {passed} passed, {failed} failed")


def test_uart_parity():
    """Test with parity enabled"""
    print("\n" + "="*60)
    print("Test 2: With Even Parity")
    print("="*60)
    
    config = UARTConfig(baud_rate=115200, data_bits=8, stop_bits=1, parity='even')
    loopback = UARTLoopback(config)
    
    test_data = [0x55, 0xAA, 0x01, 0x03, 0x7E, 0x81]
    
    for data in test_data:
        result, _ = loopback.transmit_and_receive(data)
        status = "✓ PASS" if result == data else "✗ FAIL"
        print(f"Sent: 0x{data:02X}, Received: 0x{result:02X} -> {status}")


def test_uart_error_injection():
    """Test error detection"""
    print("\n" + "="*60)
    print("Test 3: Error Detection")
    print("="*60)
    
    config = UARTConfig(baud_rate=115200, data_bits=8, stop_bits=1)
    tx = UARTTx(config)
    rx = UARTRx(config)
    
    # Corrupt the waveform by flipping a data bit
    data = 0x55
    print(f"Original data: 0x{data:02X}")
    waveform = tx.generate_waveform(data)
    
    # Flip a bit in the middle of the data section
    # Data bits start at sample 16 (start bit is 16 samples)
    flip_position = 16 + (3 * 16) + 8  # Middle of data bit 3
    if flip_position < len(waveform):
        original_bit = waveform[flip_position]
        waveform[flip_position] = 1 - waveform[flip_position]
        print(f"Flipped bit at position {flip_position} from {original_bit} to {waveform[flip_position]}")
    
    result = rx.receive_byte(waveform, verbose=True)
    print(f"Decoded result: {result}")
    print(f"Expected: 0x{data:02X}")
    print(f"Success: {result == data}")


def test_uart_edge_cases():
    """Test edge cases"""
    print("\n" + "="*60)
    print("Test 4: Edge Cases")
    print("="*60)
    
    config = UARTConfig(baud_rate=115200, data_bits=8, stop_bits=1)
    rx = UARTRx(config)
    
    # Test 1: All zeros
    print("Testing all zeros...")
    waveform = [0] * 200  # All zeros - should fail
    result = rx.receive_byte(waveform)
    print(f"All zeros waveform result: {result} (should be None)")
    
    # Test 2: All ones
    print("Testing all ones...")
    waveform = [1] * 200
    result = rx.receive_byte(waveform)
    print(f"All ones waveform result: {result} (should be None)")
    
    # Test 3: Very short waveform
    print("Testing short waveform...")
    waveform = [1, 0, 1, 0, 1, 0]  # Too short
    result = rx.receive_byte(waveform)
    print(f"Short waveform result: {result} (should be None)")


def visualize_uart_frame(data: int, samples_per_bit: int = 16):
    """Create a visual ASCII representation of the UART frame"""
    config = UARTConfig(samples_per_bit=samples_per_bit)
    tx = UARTTx(config)
    
    print(f"\nVisual UART Frame for 0x{data:02X}:")
    print(f"Data: {data:08b} (binary)")
    print(tx.get_frame_bits_string(data))
    
    # Create waveform
    waveform = tx.generate_waveform(data, samples_per_bit)
    
    # Draw the waveform
    line1 = ""
    line2 = ""
    
    # Limit display to reasonable length
    display_length = min(200, len(waveform))
    
    for i in range(display_length):
        if waveform[i] == 0:
            line1 += " "  # Space for low
            line2 += "_"  # Underscore for low
        else:
            line1 += "‾"  # Overline for high
            line2 += " "  # Space for high
    
    print("\nWaveform (first 200 samples):")
    print("  " + line1)
    print("  " + line2)
    
    # Add markers
    markers = ""
    for i in range(0, display_length, samples_per_bit):
        if i // samples_per_bit < tx.get_frame_length():
            markers += "|" + " " * (samples_per_bit - 1)
    print("  " + markers)


def generate_test_vectors():
    """Generate test vectors for RTL verification"""
    print("\n" + "="*60)
    print("Test Vectors for RTL Verification")
    print("="*60)
    
    config = UARTConfig(baud_rate=115200, data_bits=8, stop_bits=1)
    tx = UARTTx(config)
    
    test_data = [0x55, 0xAA, 0x00, 0xFF]
    
    print("\nFormat: data -> frame bits (LSB first)")
    print("-" * 50)
    
    for data in test_data:
        bits = tx.send_byte(data)
        print(f"0x{data:02X} -> {bits}")
        print(f"  Frame: {''.join(str(b) for b in bits)}")
        print(f"  Check: Start: {bits[0]}, Data: {bits[1:9]}, Stop: {bits[9:]}")
        print()


def main():
    """Run all tests"""
    print("UART Python Model Test Suite")
    print("="*60)
    
    test_uart_basic()
    test_uart_parity()
    test_uart_error_injection()
    test_uart_edge_cases()
    
    # Visual examples
    print("\n" + "="*60)
    print("Visual UART Frames")
    print("="*60)
    visualize_uart_frame(0x55)
    visualize_uart_frame(0xAA)
    visualize_uart_frame(0x00)
    visualize_uart_frame(0xFF)
    
    generate_test_vectors()
    
    print("\n" + "="*60)
    print("All tests completed!")


if __name__ == "__main__":
    main()