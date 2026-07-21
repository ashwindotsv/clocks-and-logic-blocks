"""
Scores every method x threshold combination against your manual labels.

Run this AFTER roi_comparison.py and manual_label_tool.py have both
produced their CSVs. Produces the exact table your prof asked for:

Method          | Label agreement | Classification accuracy
whole_image     | ...             | ...
bottom_half     | ...             | ...
roi_1           | ...             | ...
roi_2           | ...             | ...
roi_3           | ...             | ...

"Classification accuracy" = % of your manually labeled sample where
the automatic method's label matches your judgment. This is computed
per threshold too, so you can see which threshold is best for each
method, not just which ROI shape.
"""

import os
import pandas as pd

OUT_DIR = r"C:\Users\nayak\Desktop\MSIS_Files\IDD_CNN_inference"
ROI_PER_IMAGE_CSV = os.path.join(OUT_DIR, "roi_comparison_per_image.csv")
MANUAL_LABELS_CSV = os.path.join(OUT_DIR, "manual_ground_truth_labels.csv")

THRESHOLDS = [0.05, 0.10, 0.15, 0.20]
METHODS = ["whole_image", "bottom_half", "roi_1", "roi_2", "roi_3"]

def main():
    if not os.path.exists(ROI_PER_IMAGE_CSV):
        print(f"Missing {ROI_PER_IMAGE_CSV} - run roi_comparison.py first.")
        return
    if not os.path.exists(MANUAL_LABELS_CSV):
        print(f"Missing {MANUAL_LABELS_CSV} - run manual_label_tool.py first (need at least some labels).")
        return

    roi_df = pd.read_csv(ROI_PER_IMAGE_CSV)
    roi_df["img_id"] = roi_df["img_id"].astype(str)

    manual_df = pd.read_csv(MANUAL_LABELS_CSV)
    manual_df["img_id"] = manual_df["img_id"].astype(str)

    merged = roi_df.merge(manual_df, on="img_id", how="inner")
    print(f"Scoring against {len(merged)} manually labeled images.\n")

    if len(merged) == 0:
        print("No overlap between manual labels and ROI data - check img_id formats match.")
        return

    results = []
    for method in METHODS:
        for thresh in THRESHOLDS:
            predicted = merged[method] > thresh
            predicted_label = predicted.map({True: "non_drivable", False: "drivable"})
            correct = (predicted_label == merged["manual_label"]).sum()
            accuracy = 100 * correct / len(merged)
            results.append({
                "method": method,
                "threshold": thresh,
                "n_samples": len(merged),
                "accuracy_pct": round(accuracy, 1),
            })

    results_df = pd.DataFrame(results)
    print("=== Accuracy vs manual ground truth, per method x threshold ===")
    print(results_df.to_string(index=False))

    # Best threshold per method
    print("\n=== Best threshold per method ===")
    best_per_method = results_df.loc[results_df.groupby("method")["accuracy_pct"].idxmax()]
    print(best_per_method.to_string(index=False))

    out_path = os.path.join(OUT_DIR, "method_accuracy_vs_manual.csv")
    results_df.to_csv(out_path, index=False)
    print(f"\nSaved to: {out_path}")

if __name__ == "__main__":
    main()
