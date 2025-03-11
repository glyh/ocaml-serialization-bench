[@@@ocaml.warning "-27-30-39-44"]

type int64_list = {
  values : int64 list;
}

let rec default_int64_list 
  ?values:((values:int64 list) = [])
  () : int64_list  = {
  values;
}

type int64_list_mutable = {
  mutable values : int64 list;
}

let default_int64_list_mutable () : int64_list_mutable = {
  values = [];
}

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf Encoding} *)

let rec encode_pb_int64_list (v:int64_list) encoder = 
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.int64_as_varint x encoder;
    Pbrt.Encoder.key 1 Pbrt.Varint encoder; 
  ) v.values encoder;
  ()

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf Decoding} *)

let rec decode_pb_int64_list d =
  let v = default_int64_list_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      v.values <- List.rev v.values;
    ); continue__ := false
    | Some (1, Pbrt.Varint) -> begin
      v.values <- (Pbrt.Decoder.int64_as_varint d) :: v.values;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(int64_list), field(1)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    values = v.values;
  } : int64_list)
