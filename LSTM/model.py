import numpy as np
import torch
import torch.nn as nn
from torch.utils.data import Dataset, DataLoader
import matplotlib.pyplot as plt

loaded = np.load("aritificial_timeseries_data.npz")
X = loaded['X']
y = loaded['y']

# Train/Test split
train_size = int(len(X) * 0.8)
X_train, y_train = X[:train_size], y[:train_size]
X_test, y_test = X[train_size:], y[train_size:]

# 3. PyTorch Dataset
class TimeSeriesDataset(Dataset):
    def __init__(self, X, y):
        self.X = torch.tensor(X, dtype=torch.float32).unsqueeze(-1)  # (batch, seq_len, 1)
        self.y = torch.tensor(y, dtype=torch.float32).unsqueeze(-1)  # (batch, 1)

    def __len__(self):
        return len(self.X)

    def __getitem__(self, idx):
        return self.X[idx], self.y[idx]

train_dataset = TimeSeriesDataset(X_train, y_train)
test_dataset = TimeSeriesDataset(X_test, y_test)

train_loader = DataLoader(train_dataset, batch_size=32, shuffle=True)
test_loader = DataLoader(test_dataset, batch_size=32, shuffle=False)

# 4. Define LSTM model
class LSTMModel(nn.Module):
    def __init__(self, input_size=1, hidden_size=50, num_layers=1):
        super(LSTMModel, self).__init__()
        self.lstm = nn.LSTM(input_size, hidden_size, num_layers, batch_first=True)
        self.linear = nn.Linear(hidden_size, 1)

    def forward(self, x):
        out, _ = self.lstm(x)  # (batch, seq_len, hidden)
        out = self.linear(out[:, -1, :])  # use last output
        return out

model = LSTMModel()
loss_fn = nn.MSELoss()
optimizer = torch.optim.Adam(model.parameters(), lr=0.01)

# 5. Training loop
epochs = 30
for epoch in range(epochs):
    model.train()
    total_loss = 0
    for batch_X, batch_y in train_loader:
        optimizer.zero_grad()
        output = model(batch_X)
        loss = loss_fn(output, batch_y)
        loss.backward()
        optimizer.step()
        total_loss += loss.item()
    print(f"Epoch {epoch+1}/{epochs}, Loss: {total_loss/len(train_loader):.4f}")

# 6. Prediction
def predict(model, dataset):
    model.eval()
    preds = []
    targets = []
    with torch.no_grad():
        for batch_X, batch_y in DataLoader(dataset, batch_size=32):
            output = model(batch_X)
            preds.append(output.numpy())
            targets.append(batch_y.numpy())
    return np.concatenate(preds), np.concatenate(targets)

train_preds, train_targets = predict(model, train_dataset)
test_preds, test_targets = predict(model, test_dataset)

# 7. Plot
plt.figure(figsize=(14, 6))


plt.xlabel("Scaled Time")
plt.ylabel("Scaled Moisture ")
plt.subplot(1, 2, 1)
plt.plot(test_targets, label='Test True')
plt.plot(test_preds, label='Test Predicted')
plt.title("Test Prediction")
plt.legend()

plt.tight_layout()
plt.show()
