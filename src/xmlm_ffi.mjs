import { List } from "./gleam.mjs";

export function int_list_to_string(int_list) {
  const array = new Uint8Array(int_list.toArray());
  const decoder = new TextDecoder("utf-8", { fatal: true });
  return decoder.decode(array);
}

export function bit_array_to_list(bit_array) {
  return List.fromArray(bit_array.rawBuffer);
}
