[@@@ocaml.warning "-27-30-39-44"]

type str = {
  str : string;
}

let rec default_str 
  ?str:((str:string) = "")
  () : str  = {
  str;
}

type str_mutable = {
  mutable str : string;
}

let default_str_mutable () : str_mutable = {
  str = "";
}

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf Encoding} *)

let rec encode_pb_str (v:str) encoder = 
  Pbrt.Encoder.string v.str encoder;
  Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  ()

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf Decoding} *)

let rec decode_pb_str d =
  let v = default_str_mutable () in
  let continue__= ref true in
  let str_is_set = ref false in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.str <- Pbrt.Decoder.string d; str_is_set := true;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(str), field(1)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  begin if not !str_is_set then Pbrt.Decoder.missing_field "str" end;
  ({
    str = v.str;
  } : str)
