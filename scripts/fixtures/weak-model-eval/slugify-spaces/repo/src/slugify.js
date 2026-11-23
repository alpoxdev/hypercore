// Turns a title into a lowercase, hyphen-separated slug.
export function slugify(title) {
  return title.toLowerCase().replace(/\s/g, "-");
}
