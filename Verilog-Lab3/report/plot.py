import matplotlib.pyplot as plt

# Data
cache_size = [2, 4, 8, 16, 32]
cycle = [681, 674, 682, 698, 730]
area = [8374.744, 16431.352, 31500.252, 61267.248, 115278.814]

# -------------------------------
# Plot 1: Cache Size vs Cycle
# -------------------------------
plt.figure(figsize=(7,5))
plt.plot(cache_size, cycle, marker='o', linewidth=2)

plt.xscale("log", base=2)
plt.xticks(cache_size, cache_size)
plt.xlabel("Cache Size (sets, log scale)")
plt.ylabel("Cycle Count")
plt.title("Cache Size vs Cycle Count (I4 Testcase)")
plt.grid(True, which="both", linestyle="--")

# Annotate each point
for x, y in zip(cache_size, cycle):
    plt.text(x, y + 3, f"{y}", ha='center', fontsize=9)

plt.tight_layout()
plt.show()

def annotate_points(xs, ys, y_offset_factor=0.05):
    for i, (x, y) in enumerate(zip(xs, ys)):
        # compute upward or downward offset based on slope around point
        if i == 0:
            slope = ys[i+1] - ys[i]
        elif i == len(ys) - 1:
            slope = ys[i] - ys[i-1]
        else:
            slope = (ys[i+1] - ys[i-1]) / 2
        
        # choose offset direction (if slope is positive, shift upward)
        direction = 1 if slope >= 0 else -1
        
        offset = direction * (max(ys) * y_offset_factor)
        
        plt.text(x * 1.01, y + offset, f"{ys[i]:.1f}", 
                 ha='left', va='center', fontsize=9)


# ============================================
# Plot 2: Cache Size vs System Area (Improved)
# ============================================
plt.figure(figsize=(7,5))
plt.plot(cache_size, area, marker='o', linewidth=2)

plt.xscale("log", base=2)
plt.xticks(cache_size, cache_size)
plt.xlabel("Cache Size (sets, log scale)")
plt.ylabel("Area")
plt.title("Cache Size vs Systhesized Area")
plt.grid(True, which="both", linestyle="--")

# annotate with smart offsets
annotate_points(cache_size, area)

plt.tight_layout()
plt.show()