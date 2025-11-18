import torch
from torchvision import transforms
from PIL import Image
import sys

model = torch.jit.load("model/traced_model.pt")
model.eval()

preprocess = transforms.Compose([
    transforms.Resize(256),
    transforms.CenterCrop(224),
    transforms.ToTensor()
])

def predict(image_path):
    image = Image.open(image_path).convert("RGB")
    input_tensor = preprocess(image).unsqueeze(0)
    with torch.no_grad():
        output = model(input_tensor)
        class_id = output.argmax(dim=1).item()
        print(f"Predicted class ID: {class_id}")

if __name__ == "__main__":
    predict(sys.argv[1])
