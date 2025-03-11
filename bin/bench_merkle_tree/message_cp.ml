[@@@ocaml.warning "-27-32-37-60"]

type ro = Capnp.Message.ro
type rw = Capnp.Message.rw

module type S = sig
  module MessageWrapper : Capnp.RPC.S
  type 'cap message_t = 'cap MessageWrapper.Message.t
  type 'a reader_t = 'a MessageWrapper.StructStorage.reader_t
  type 'a builder_t = 'a MessageWrapper.StructStorage.builder_t


  module Reader : sig
    type array_t
    type builder_array_t
    type pointer_t = ro MessageWrapper.Slice.t option
    val of_pointer : pointer_t -> 'a reader_t
    module MerkleTree : sig
      type struct_t = [`MerkleTree_9e956644e2a997e1]
      type t = struct_t reader_t
      type unnamed_union_t =
        | Leaf
        | Internal of (ro, [`MerkleTree_9e956644e2a997e1] reader_t, array_t) Capnp.Array.t
        | Undefined of int
      val get : t -> unnamed_union_t
      val hash_get : t -> int64
      val hash_get_int_exn : t -> int
      val of_message : 'cap message_t -> t
      val of_builder : struct_t builder_t -> t
    end
  end

  module Builder : sig
    type array_t = Reader.builder_array_t
    type reader_array_t = Reader.array_t
    type pointer_t = rw MessageWrapper.Slice.t
    module MerkleTree : sig
      type struct_t = [`MerkleTree_9e956644e2a997e1]
      type t = struct_t builder_t
      type unnamed_union_t =
        | Leaf
        | Internal of (rw, [`MerkleTree_9e956644e2a997e1] builder_t, array_t) Capnp.Array.t
        | Undefined of int
      val get : t -> unnamed_union_t
      val leaf_set : t -> unit
      val internal_set : t -> (rw, [`MerkleTree_9e956644e2a997e1] builder_t, array_t) Capnp.Array.t -> (rw, [`MerkleTree_9e956644e2a997e1] builder_t, array_t) Capnp.Array.t
      val internal_set_list : t -> [`MerkleTree_9e956644e2a997e1] builder_t list -> (rw, [`MerkleTree_9e956644e2a997e1] builder_t, array_t) Capnp.Array.t
      val internal_set_array : t -> [`MerkleTree_9e956644e2a997e1] builder_t array -> (rw, [`MerkleTree_9e956644e2a997e1] builder_t, array_t) Capnp.Array.t
      val internal_init : t -> int -> (rw, [`MerkleTree_9e956644e2a997e1] builder_t, array_t) Capnp.Array.t
      val hash_get : t -> int64
      val hash_get_int_exn : t -> int
      val hash_set : t -> int64 -> unit
      val hash_set_int : t -> int -> unit
      val of_message : rw message_t -> t
      val to_message : t -> rw message_t
      val to_reader : t -> struct_t reader_t
      val init_root : ?message_size:int -> unit -> t
      val init_pointer : pointer_t -> t
    end
  end
end

module MakeRPC(MessageWrapper : Capnp.RPC.S) = struct
  type 'a reader_t = 'a MessageWrapper.StructStorage.reader_t
  type 'a builder_t = 'a MessageWrapper.StructStorage.builder_t
  module CamlBytes = Bytes
  module DefaultsMessage_ = Capnp.BytesMessage

  let _builder_defaults_message =
    let message_segments = [
      Bytes.unsafe_of_string "\
      ";
    ] in
    DefaultsMessage_.Message.readonly
      (DefaultsMessage_.Message.of_storage message_segments)

  let invalid_msg = Capnp.Message.invalid_msg

  include Capnp.Runtime.BuilderInc.Make(MessageWrapper)

  type 'cap message_t = 'cap MessageWrapper.Message.t

  module DefaultsCopier_ =
    Capnp.Runtime.BuilderOps.Make(Capnp.BytesMessage)(MessageWrapper)

  let _reader_defaults_message =
    MessageWrapper.Message.create
      (DefaultsMessage_.Message.total_size _builder_defaults_message)


  module Reader = struct
    type array_t = ro MessageWrapper.ListStorage.t
    type builder_array_t = rw MessageWrapper.ListStorage.t
    type pointer_t = ro MessageWrapper.Slice.t option
    let of_pointer = RA_.deref_opt_struct_pointer

    module MerkleTree = struct
      type struct_t = [`MerkleTree_9e956644e2a997e1]
      type t = struct_t reader_t
      let leaf_get x = ()
      let has_internal x =
        RA_.has_field x 0
      let internal_get x = 
        RA_.get_struct_list x 0
      let internal_get_list x =
        Capnp.Array.to_list (internal_get x)
      let internal_get_array x =
        Capnp.Array.to_array (internal_get x)
      type unnamed_union_t =
        | Leaf
        | Internal of (ro, [`MerkleTree_9e956644e2a997e1] reader_t, array_t) Capnp.Array.t
        | Undefined of int
      let get x =
        match RA_.get_uint16 ~default:0 x 8 with
        | 0 -> Leaf
        | 1 -> Internal (internal_get x)
        | v -> Undefined v
      let hash_get x =
        RA_.get_int64 ~default:(0L) x 0
      let hash_get_int_exn x =
        Capnp.Runtime.Util.int_of_int64_exn (hash_get x)
      let of_message x = RA_.get_root_struct (RA_.Message.readonly x)
      let of_builder x = Some (RA_.StructStorage.readonly x)
    end
  end

  module Builder = struct
    type array_t = Reader.builder_array_t
    type reader_array_t = Reader.array_t
    type pointer_t = rw MessageWrapper.Slice.t

    module MerkleTree = struct
      type struct_t = [`MerkleTree_9e956644e2a997e1]
      type t = struct_t builder_t
      let leaf_get x = ()
      let leaf_set x =
        BA_.set_void ~discr:{BA_.Discr.value=0; BA_.Discr.byte_ofs=8} x
      let has_internal x =
        BA_.has_field x 0
      let internal_get x = 
        BA_.get_struct_list ~data_words:2 ~pointer_words:1 x 0
      let internal_get_list x =
        Capnp.Array.to_list (internal_get x)
      let internal_get_array x =
        Capnp.Array.to_array (internal_get x)
      let internal_set x v =
        BA_.set_struct_list ~data_words:2 ~pointer_words:1 ~discr:{BA_.Discr.value=1; BA_.Discr.byte_ofs=8} x 0 v
      let internal_init x n =
        BA_.init_struct_list ~data_words:2 ~pointer_words:1 ~discr:{BA_.Discr.value=1; BA_.Discr.byte_ofs=8} x 0 n
      let internal_set_list x v =
        let builder = internal_init x (List.length v) in
        let () = List.iteri (fun i a -> Capnp.Array.set builder i a) v in
        builder
      let internal_set_array x v =
        let builder = internal_init x (Array.length v) in
        let () = Array.iteri (fun i a -> Capnp.Array.set builder i a) v in
        builder
      type unnamed_union_t =
        | Leaf
        | Internal of (rw, [`MerkleTree_9e956644e2a997e1] builder_t, array_t) Capnp.Array.t
        | Undefined of int
      let get x =
        match BA_.get_uint16 ~default:0 x 8 with
        | 0 -> Leaf
        | 1 -> Internal (internal_get x)
        | v -> Undefined v
      let hash_get x =
        BA_.get_int64 ~default:(0L) x 0
      let hash_get_int_exn x =
        Capnp.Runtime.Util.int_of_int64_exn (hash_get x)
      let hash_set x v =
        BA_.set_int64 ~default:(0L) x 0 v
      let hash_set_int x v = hash_set x (Int64.of_int v)
      let of_message x = BA_.get_root_struct ~data_words:2 ~pointer_words:1 x
      let to_message x = x.BA_.NM.StructStorage.data.MessageWrapper.Slice.msg
      let to_reader x = Some (RA_.StructStorage.readonly x)
      let init_root ?message_size () =
        BA_.alloc_root_struct ?message_size ~data_words:2 ~pointer_words:1 ()
      let init_pointer ptr =
        BA_.init_struct_pointer ptr ~data_words:2 ~pointer_words:1
    end
  end

  module Client = struct
  end

  module Service = struct
  end
  module MessageWrapper = MessageWrapper
end

module Make(M:Capnp.MessageSig.S) = MakeRPC(Capnp.RPC.None(M))
