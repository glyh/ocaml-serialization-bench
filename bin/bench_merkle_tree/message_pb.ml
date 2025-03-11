[@@@ocaml.warning "-27-30-39-44"]

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

let rec default_empty = ()

let rec default_merkle_tree_kind (): merkle_tree_kind = Leaf

and default_merkle_tree 
  ?hash:((hash:int64) = 0L)
  ?kind:((kind:merkle_tree_kind) = Leaf)
  () : merkle_tree  = {
  hash;
  kind;
}

and default_children 
  ?children:((children:merkle_tree list) = [])
  () : children  = {
  children;
}

type merkle_tree_mutable = {
  mutable hash : int64;
  mutable kind : merkle_tree_kind;
}

let default_merkle_tree_mutable () : merkle_tree_mutable = {
  hash = 0L;
  kind = Leaf;
}

type children_mutable = {
  mutable children : merkle_tree list;
}

let default_children_mutable () : children_mutable = {
  children = [];
}

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf Encoding} *)

let rec encode_pb_empty (v:empty) encoder = 
()

let rec encode_pb_merkle_tree_kind (v:merkle_tree_kind) encoder = 
  begin match v with
  | Leaf ->
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
    Pbrt.Encoder.empty_nested encoder
  | Internal x ->
    Pbrt.Encoder.nested encode_pb_children x encoder;
    Pbrt.Encoder.key 3 Pbrt.Bytes encoder; 
  end

and encode_pb_merkle_tree (v:merkle_tree) encoder = 
  Pbrt.Encoder.int64_as_varint v.hash encoder;
  Pbrt.Encoder.key 1 Pbrt.Varint encoder; 
  begin match v.kind with
  | Leaf ->
    Pbrt.Encoder.empty_nested encoder;
    Pbrt.Encoder.key 2 Pbrt.Bytes encoder; 
  | Internal x ->
    Pbrt.Encoder.nested encode_pb_children x encoder;
    Pbrt.Encoder.key 3 Pbrt.Bytes encoder; 
  end;
  ()

and encode_pb_children (v:children) encoder = 
  Pbrt.List_util.rev_iter_with (fun x encoder -> 
    Pbrt.Encoder.nested encode_pb_merkle_tree x encoder;
    Pbrt.Encoder.key 1 Pbrt.Bytes encoder; 
  ) v.children encoder;
  ()

[@@@ocaml.warning "-27-30-39"]

(** {2 Protobuf Decoding} *)

let rec decode_pb_empty d =
  match Pbrt.Decoder.key d with
  | None -> ();
  | Some (_, pk) -> 
    Pbrt.Decoder.unexpected_payload "Unexpected fields in empty message(empty)" pk

let rec decode_pb_merkle_tree_kind d = 
  let rec loop () = 
    let ret:merkle_tree_kind = match Pbrt.Decoder.key d with
      | None -> Pbrt.Decoder.malformed_variant "merkle_tree_kind"
      | Some (2, _) -> begin 
        Pbrt.Decoder.empty_nested d ;
        (Leaf : merkle_tree_kind)
      end
      | Some (3, _) -> (Internal (decode_pb_children (Pbrt.Decoder.nested d)) : merkle_tree_kind) 
      | Some (n, payload_kind) -> (
        Pbrt.Decoder.skip d payload_kind; 
        loop () 
      )
    in
    ret
  in
  loop ()

and decode_pb_merkle_tree d =
  let v = default_merkle_tree_mutable () in
  let continue__= ref true in
  let hash_is_set = ref false in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
    ); continue__ := false
    | Some (1, Pbrt.Varint) -> begin
      v.hash <- Pbrt.Decoder.int64_as_varint d; hash_is_set := true;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(merkle_tree), field(1)" pk
    | Some (2, Pbrt.Bytes) -> begin
      Pbrt.Decoder.empty_nested d;
      v.kind <- Leaf;
    end
    | Some (2, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(merkle_tree), field(2)" pk
    | Some (3, Pbrt.Bytes) -> begin
      v.kind <- Internal (decode_pb_children (Pbrt.Decoder.nested d));
    end
    | Some (3, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(merkle_tree), field(3)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  begin if not !hash_is_set then Pbrt.Decoder.missing_field "hash" end;
  ({
    hash = v.hash;
    kind = v.kind;
  } : merkle_tree)

and decode_pb_children d =
  let v = default_children_mutable () in
  let continue__= ref true in
  while !continue__ do
    match Pbrt.Decoder.key d with
    | None -> (
      v.children <- List.rev v.children;
    ); continue__ := false
    | Some (1, Pbrt.Bytes) -> begin
      v.children <- (decode_pb_merkle_tree (Pbrt.Decoder.nested d)) :: v.children;
    end
    | Some (1, pk) -> 
      Pbrt.Decoder.unexpected_payload "Message(children), field(1)" pk
    | Some (_, payload_kind) -> Pbrt.Decoder.skip d payload_kind
  done;
  ({
    children = v.children;
  } : children)
