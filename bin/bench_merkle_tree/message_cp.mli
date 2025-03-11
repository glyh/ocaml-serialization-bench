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

module MakeRPC(MessageWrapper : Capnp.RPC.S) : sig
  include S with module MessageWrapper = MessageWrapper

  module Client : sig
  end

  module Service : sig
  end
end

module Make(M : Capnp.MessageSig.S) : module type of MakeRPC(Capnp.RPC.None(M))
