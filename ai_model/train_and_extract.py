import torch

# Fix the seed for reproducible matrix generation
torch.manual_seed(100)

# 1. Create a 2x2 Matrix A (e.g., intermediate layer activations)
mat_a = torch.randn(2, 2)
# 2. Create a 2x2 Matrix B (e.g., weights of a dense neural network layer)
mat_b = torch.randn(2, 2)

# 3. Quantize both matrices to 8-bit integers by scaling them by 50
quant_a = (mat_a * 50).round().to(torch.int8)
quant_b = (mat_b * 50).round().to(torch.int8)

print("--- Quantized Matrix A (Inputs from Left) ---")
print(quant_a)
print("\n--- Quantized Matrix B (Weights from Top) ---")
print(quant_b)

# 4. Compute the Golden Reference Matrix Product using integer math
# We cast to int32 here to prevent Python container overflow during verification
golden_matrix_out = torch.matmul(quant_a.to(torch.int32), quant_b.to(torch.int32))

print("\n--- Golden Matrix Output (What our 2x2 Array must calculate) ---")
print(golden_matrix_out)


#`The code below is what was exactly used for testing the MAC cell in Verilog, particularly checking for just one neuron. 
# It is a simple PyTorch script that defines a tiny neural network, quantizes its weights, and computes a golden reference output.
# This output can be used to verify that the hardware implementation of the MAC cell produces the same result.
# import torch
# import torch.nn as nn

# # 1. Fix the random seed so your results match exactly every time you run it
# torch.manual_seed(42)

# # 2. Define a simple 1-layer Neural Network (2 Inputs, 1 Output)

# # This simulates our tiny AI accelerator target
# class TinyEdgeAI(nn.Module):
#     def __init__(self):
#         super(TinyEdgeAI, self).__init__()
#         self.fc = nn.Linear(in_features=2, out_features=1, bias=False)

#     def forward(self, x):
#         return self.fc(x)

# # 3. Instantiate the model
# model = TinyEdgeAI()

# # 4. Pretend this model is trained. Let's look at its raw floating-point weights:
# raw_weights = model.fc.weight.data
# print("--- Python Float Weights ---")
# print(raw_weights)

# # 5. EDGE AI TRICK: Quantize the weights to 8-bit integers (scale by 100 for simplicity)
# quantized_weights = (raw_weights * 100).round().to(torch.int8)
# print("\n--- Quantized INT8 Weights for Verilog ---")
# print(quantized_weights)

# # Example resulting integers: tensor([[ 55, -15]], dtype=torch.int8)

# # 6. Define a mock input vector (e.g., sensor data reading)
# mock_input = torch.tensor([[2.0, 4.0]])
# quantized_input = mock_input.to(torch.int8)

# # 7. Compute the golden reference value in Python
# # Matrix multiplication: (2 * 55) + (4 * -15) = 110 - 60 = 50
# golden_output = torch.matmul(quantized_input, quantized_weights.t())
# print("\n--- Golden Reference Output (What our hardware MUST match) ---")
# print(golden_output.item())

# # for running this, ensure you have PyTorch installed in your Python environment. You can install it via pip if you haven't done so already:
# # pip install torch

# # To create a virtual environment and install PyTorch, you can do the following:
# # 1. Create a virtual environment (optional but recommended)
# # python -m venv ai_env
# # Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope Process
# # .\ai_env\Scripts\Activate.ps1
# # 2. Install PyTorch
# # pip install torch