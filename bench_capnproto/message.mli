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
    module Int64List : sig
      type struct_t = [`Int64List_c75fd268911bb1b9]
      type t = struct_t reader_t
      val has_values : t -> bool
      val values_get : t -> (ro, int64, array_t) Capnp.Array.t
      val values_get_list : t -> int64 list
      val values_get_array : t -> int64 array
      val of_message : 'cap message_t -> t
      val of_builder : struct_t builder_t -> t
    end
  end

  module Builder : sig
    type array_t = Reader.builder_array_t
    type reader_array_t = Reader.array_t
    type pointer_t = rw MessageWrapper.Slice.t
    module Int64List : sig
      type struct_t = [`Int64List_c75fd268911bb1b9]
      type t = struct_t builder_t
      val has_values : t -> bool
      val values_get : t -> (rw, int64, array_t) Capnp.Array.t
      val values_get_list : t -> int64 list
      val values_get_array : t -> int64 array
      val values_set : t -> (rw, int64, array_t) Capnp.Array.t -> (rw, int64, array_t) Capnp.Array.t
      val values_set_list : t -> int64 list -> (rw, int64, array_t) Capnp.Array.t
      val values_set_array : t -> int64 array -> (rw, int64, array_t) Capnp.Array.t
      val values_init : t -> int -> (rw, int64, array_t) Capnp.Array.t
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
