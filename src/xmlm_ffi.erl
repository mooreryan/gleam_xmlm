-module(xmlm_ffi).

-export([bit_array_to_list/1, int_list_to_string/1]).

bit_array_to_list(X) -> binary:bin_to_list(X).

int_list_to_string(X) -> list_to_binary(X).
