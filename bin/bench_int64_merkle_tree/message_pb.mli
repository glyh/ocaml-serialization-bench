
(** Code for message_pb.proto *)

(* generated from "message_pb.proto", do not edit *)



(** {2 Types} *)

type str = {
  str : string;
}


(** {2 Basic values} *)

val default_str : 
  ?str:string ->
  unit ->
  str
(** [default_str ()] is the default value for type [str] *)


(** {2 Protobuf Encoding} *)

val encode_pb_str : str -> Pbrt.Encoder.t -> unit
(** [encode_pb_str v encoder] encodes [v] with the given [encoder] *)


(** {2 Protobuf Decoding} *)

val decode_pb_str : Pbrt.Decoder.t -> str
(** [decode_pb_str decoder] decodes a [str] binary value from [decoder] *)
