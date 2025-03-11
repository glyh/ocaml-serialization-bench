
(** Code for message_pb.proto *)

(* generated from "message_pb.proto", do not edit *)



(** {2 Types} *)

type int64_list = {
  values : int64 list;
}


(** {2 Basic values} *)

val default_int64_list : 
  ?values:int64 list ->
  unit ->
  int64_list
(** [default_int64_list ()] is the default value for type [int64_list] *)


(** {2 Protobuf Encoding} *)

val encode_pb_int64_list : int64_list -> Pbrt.Encoder.t -> unit
(** [encode_pb_int64_list v encoder] encodes [v] with the given [encoder] *)


(** {2 Protobuf Decoding} *)

val decode_pb_int64_list : Pbrt.Decoder.t -> int64_list
(** [decode_pb_int64_list decoder] decodes a [int64_list] binary value from [decoder] *)
