# README feature panels

These compositions use the current app captures in `docs/screenshots`, with explanatory copy and workflow diagrams. The README uses them instead of a raw screenshot gallery.

Regenerate after refreshing the app captures:

```bash
scripts/render-promo.sh --readme
```

The renderer is `scripts/marketing/ReadmeScreens.swift`. It produces five 2880 × 1800 PNGs: wheels, focused tools, saved Recipes, archives and customization. The artwork preserves the shipping app’s typography, teal selection and dark surfaces. Raw captures remain available in `docs/screenshots`.
