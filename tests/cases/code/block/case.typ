// Block code rendering — left-inset, mono font.
#import "../../../../src/lib.typ": tufte
#show: tufte.with(title: [Code block])

Inline `code` first, then a block:

```python
def fit(points, n_iter=100):
    """Cubic Bezier least-squares fit."""
    for _ in range(n_iter):
        update(points)
    return points
```

Body text after.
