import os
import time
import random
import numpy as np
import torch
import torch.nn as nn
from torch.utils.data import Dataset, DataLoader
from torchvision import transforms
from PIL import Image
from tqdm import tqdm
from sklearn.metrics import confusion_matrix
import matplotlib.pyplot as plt

# =====================================================
# 0. REPRODUCIBILITY
# =====================================================
random.seed(42)
np.random.seed(42)
torch.manual_seed(42)
if torch.cuda.is_available():
    torch.cuda.manual_seed_all(42)

# =====================================================
# 1. DATASET
# =====================================================
class BDDClassificationDataset(Dataset):
    def __init__(self, root_dir, class_groups, transform=None):
        self.samples = []
        self.transform = transform
        self.class_names = list(class_groups.keys())
        self.class_to_idx = {name: i for i, name in enumerate(self.class_names)}

        for cls_name, source_folders in class_groups.items():
            label_idx = self.class_to_idx[cls_name]
            for folder in source_folders:
                folder_path = os.path.join(root_dir, folder)
                if not os.path.isdir(folder_path):
                    continue
                for fname in os.listdir(folder_path):
                    if fname.lower().endswith((".jpg", ".jpeg", ".png")):
                        self.samples.append(
                            (os.path.join(folder_path, fname), label_idx)
                        )

    def __len__(self):
        return len(self.samples)

    def __getitem__(self, idx):
        path, label = self.samples[idx]
        image = Image.open(path).convert("RGB")
        if self.transform:
            image = self.transform(image)
        return image, label


class SimpleCNN(nn.Module):
    def __init__(self, num_classes):
        super().__init__()
        self.features = nn.Sequential(
            nn.Conv2d(3, 32, kernel_size=3, padding=1), nn.ReLU(), nn.MaxPool2d(2),
            nn.Conv2d(32, 64, kernel_size=3, padding=1), nn.ReLU(), nn.MaxPool2d(2),
            nn.Conv2d(64, 128, kernel_size=3, padding=1), nn.ReLU(), nn.MaxPool2d(2),
        )
        self.classifier = nn.Sequential(
            nn.Flatten(),
            nn.Linear(128 * 8 * 8, 128),
            nn.ReLU(),
            nn.Dropout(0.5),
            nn.Linear(128, num_classes)
        )

    def forward(self, x):
        x = self.features(x)
        x = self.classifier(x)
        return x


def run_validation(model, val_loader, device, class_names):
    model.eval()
    class_correct = {name: 0 for name in class_names}
    class_total = {name: 0 for name in class_names}
    all_labels, all_preds = [], []

    with torch.no_grad():
        for images, labels in tqdm(val_loader, desc="Validating"):
            images, labels = images.to(device), labels.to(device)
            outputs = model(images)
            _, predicted = torch.max(outputs, 1)

            all_labels.extend(labels.cpu().numpy())
            all_preds.extend(predicted.cpu().numpy())

            for label, pred in zip(labels, predicted):
                cls_name = class_names[label.item()]
                class_total[cls_name] += 1
                if label == pred:
                    class_correct[cls_name] += 1

    return class_correct, class_total, all_labels, all_preds


def save_confusion_matrix(all_labels, all_preds, class_names, filename):
    cm = confusion_matrix(all_labels, all_preds)
    fig, ax = plt.subplots(figsize=(6, 5))
    im = ax.imshow(cm, cmap="Blues")
    ax.set_xticks(range(len(class_names)))
    ax.set_yticks(range(len(class_names)))
    ax.set_xticklabels(class_names, rotation=45)
    ax.set_yticklabels(class_names)
    ax.set_xlabel("Predicted")
    ax.set_ylabel("True")
    ax.set_title("Confusion Matrix (Best Model)")
    for i in range(cm.shape[0]):
        for j in range(cm.shape[1]):
            ax.text(j, i, str(cm[i, j]), ha="center", va="center",
                     color="white" if cm[i, j] > cm.max() / 2 else "black")
    fig.colorbar(im)
    plt.tight_layout()
    plt.savefig(filename)
    plt.show()
    print(f"Confusion matrix saved as {filename}")


def save_training_curves(train_losses, val_accuracies):
    plt.figure(figsize=(8, 5))
    plt.plot(train_losses, label="Training Loss")
    plt.xlabel("Epoch")
    plt.ylabel("Loss")
    plt.title("Training Loss over Epochs")
    plt.legend()
    plt.grid(True)
    plt.savefig("training_loss.png")
    plt.show()

    plt.figure(figsize=(8, 5))
    plt.plot(val_accuracies, label="Validation Accuracy")
    plt.xlabel("Epoch")
    plt.ylabel("Accuracy (%)")
    plt.title("Validation Accuracy over Epochs")
    plt.legend()
    plt.grid(True)
    plt.savefig("validation_accuracy.png")
    plt.show()

    print("Saved training_loss.png and validation_accuracy.png")


# =====================================================
# MAIN
# =====================================================
def main():
    CLASS_GROUPS = {
        "car": ["car"],
        "person": ["person"],
        "heavy_vehicle": ["bus", "truck"],
        "two_wheeler": ["bike", "motor", "rider"],
    }

    train_transform = transforms.Compose([
        transforms.RandomHorizontalFlip(),
        transforms.RandomRotation(5),
        transforms.ColorJitter(brightness=0.2, contrast=0.2),
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
    ])

    val_transform = transforms.Compose([
        transforms.ToTensor(),
        transforms.Normalize(mean=[0.485, 0.456, 0.406], std=[0.229, 0.224, 0.225])
    ])

    train_dataset = BDDClassificationDataset(
        r"C:\Users\nayak\Desktop\BDD100K_Balanced\train", CLASS_GROUPS, train_transform
    )
    val_dataset = BDDClassificationDataset(
        r"C:\Users\nayak\Desktop\BDD100K_Balanced\val", CLASS_GROUPS, val_transform
    )

    device = torch.device("cuda" if torch.cuda.is_available() else "cpu")

    train_loader = DataLoader(
        train_dataset, batch_size=64, shuffle=True,
        num_workers=4, pin_memory=torch.cuda.is_available(),
        persistent_workers=True
    )
    val_loader = DataLoader(
        val_dataset, batch_size=64, shuffle=False,
        num_workers=4, pin_memory=torch.cuda.is_available(),
        persistent_workers=True
    )

    print(f"Classes: {train_dataset.class_names}")
    print(f"Train samples: {len(train_dataset)}, Val samples: {len(val_dataset)}")
    print(f"Using device: {device}")

    model = SimpleCNN(num_classes=len(train_dataset.class_names)).to(device)

    total_params = sum(p.numel() for p in model.parameters() if p.requires_grad)
    print(f"Trainable Parameters: {total_params:,}")

    criterion = nn.CrossEntropyLoss()
    optimizer = torch.optim.Adam(model.parameters(), lr=0.001)
    scheduler = torch.optim.lr_scheduler.StepLR(optimizer, step_size=3, gamma=0.1)

    EPOCHS = 10
    best_acc = 0.0
    train_losses = []
    val_accuracies = []

    for epoch in range(EPOCHS):
        start_time = time.time()

        model.train()
        running_loss = 0.0
        train_bar = tqdm(train_loader, desc=f"Epoch {epoch+1}/{EPOCHS} [train]")
        for images, labels in train_bar:
            images, labels = images.to(device), labels.to(device)

            optimizer.zero_grad()
            outputs = model(images)
            loss = criterion(outputs, labels)
            loss.backward()
            optimizer.step()

            running_loss += loss.item()
            train_bar.set_postfix(loss=loss.item())

        class_correct, class_total, _, _ = run_validation(
            model, val_loader, device, train_dataset.class_names
        )

        overall_acc = 100 * sum(class_correct.values()) / sum(class_total.values())
        current_lr = optimizer.param_groups[0]['lr']
        elapsed = time.time() - start_time
        epoch_loss = running_loss / len(train_loader)

        train_losses.append(epoch_loss)
        val_accuracies.append(overall_acc)

        print(f"Epoch {epoch+1}/{EPOCHS} - Loss: {epoch_loss:.4f} "
              f"- Overall Val Acc: {overall_acc:.2f}% - LR: {current_lr:.6f}")
        for cls_name in train_dataset.class_names:
            if class_total[cls_name] > 0:
                acc = 100 * class_correct[cls_name] / class_total[cls_name]
                print(f"    {cls_name:15s}: {acc:.2f}% ({class_correct[cls_name]}/{class_total[cls_name]})")
        print(f"Epoch time: {elapsed:.1f} sec")

        scheduler.step()

        if overall_acc > best_acc:
            best_acc = overall_acc
            torch.save({
                "epoch": epoch + 1,
                "model_state_dict": model.state_dict(),
                "optimizer_state_dict": optimizer.state_dict(),
                "best_acc": best_acc,
            }, "best_bdd_classifier.pth")
            print(f"    Best model updated! Best Validation Accuracy: {best_acc:.2f}%")

    print(f"\nTraining complete. Best Val Acc: {best_acc:.2f}%")

    save_training_curves(train_losses, val_accuracies)

    print("\nReloading best model for confusion matrix...")
    checkpoint = torch.load("best_bdd_classifier.pth", map_location=device)
    model.load_state_dict(checkpoint["model_state_dict"])
    print(f"Loaded checkpoint from epoch {checkpoint['epoch']} (Val Acc: {checkpoint['best_acc']:.2f}%)")

    _, _, all_labels, all_preds = run_validation(
        model, val_loader, device, train_dataset.class_names
    )
    save_confusion_matrix(all_labels, all_preds, train_dataset.class_names, "confusion_matrix.png")


if __name__ == "__main__":
    main()