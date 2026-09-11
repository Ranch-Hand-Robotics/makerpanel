export function thumbnailVariants(panel, manifest) {
  const generated = manifest?.panels?.[panel.slug];
  if (typeof generated?.light === 'string' && typeof generated?.dark === 'string') {
    return { light: generated.light, dark: generated.dark };
  }
  const value = typeof panel.thumbnail === 'string' ? panel.thumbnail : '';
  if (!value || /makerpanel\.(png|jpg)|makericon\./i.test(value)) return null;
  return { light: value, dark: value };
}