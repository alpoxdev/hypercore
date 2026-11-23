// Returns the items on a 1-based page.
export function paginate(items, page, size) {
  const start = (page - 1) * size;
  return items.slice(start, start + size - 1);
}
