
(** Code for message_pb.proto *)

(* generated from "message_pb.proto", do not edit *)



(** {2 Types} *)

type empty = unit

type merkle_tree_kind =
  | Leaf
  | Internal of children

and merkle_tree = {
  hash : int64;
  kind : merkle_tree_kind;
}

and children = {
  children : merkle_tree list;
}


(** {2 Basic values} *)

val default_empty : unit
(** [default_empty ()] is the default value for type [empty] *)

val default_merkle_tree_kind : unit -> merkle_tree_kind
(** [default_merkle_tree_kind ()] is the default value for type [merkle_tree_kind] *)

val default_merkle_tree : 
  ?hash:int64 ->
  ?kind:merkle_tree_kind ->
  unit ->
  merkle_tree
(** [default_merkle_tree ()] is the default value for type [merkle_tree] *)

val default_children : 
  ?children:merkle_tree list ->
  unit ->
  children
(** [default_children ()] is the default value for type [children] *)


(** {2 Protobuf Encoding} *)

val encode_pb_empty : empty -> Pbrt.Encoder.t -> unit
(** [encode_pb_empty v encoder] encodes [v] with the given [encoder] *)

val encode_pb_merkle_tree_kind : merkle_tree_kind -> Pbrt.Encoder.t -> unit
(** [encode_pb_merkle_tree_kind v encoder] encodes [v] with the given [encoder] *)

val encode_pb_merkle_tree : merkle_tree -> Pbrt.Encoder.t -> unit
(** [encode_pb_merkle_tree v encoder] encodes [v] with the given [encoder] *)

val encode_pb_children : children -> Pbrt.Encoder.t -> unit
(** [encode_pb_children v encoder] encodes [v] with the given [encoder] *)


(** {2 Protobuf Decoding} *)

val decode_pb_empty : Pbrt.Decoder.t -> empty
(** [decode_pb_empty decoder] decodes a [empty] binary value from [decoder] *)

val decode_pb_merkle_tree_kind : Pbrt.Decoder.t -> merkle_tree_kind
(** [decode_pb_merkle_tree_kind decoder] decodes a [merkle_tree_kind] binary value from [decoder] *)

val decode_pb_merkle_tree : Pbrt.Decoder.t -> merkle_tree
(** [decode_pb_merkle_tree decoder] decodes a [merkle_tree] binary value from [decoder] *)

val decode_pb_children : Pbrt.Decoder.t -> children
(** [decode_pb_children decoder] decodes a [children] binary value from [decoder] *)
