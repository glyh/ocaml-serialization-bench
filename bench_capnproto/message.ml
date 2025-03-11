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

    module Int64List = struct
      type struct_t = [`Int64List_c75fd268911bb1b9]
      type t = struct_t reader_t
      let has_values x =
        RA_.has_field x 0
      let values_get x =
        RA_.get_int64_list x 0
      let values_get_list x =
        Capnp.Array.to_list (values_get x)
      let values_get_array x =
        Capnp.Array.to_array (values_get x)
      let of_message x = RA_.get_root_struct (RA_.Message.readonly x)
      let of_builder x = Some (RA_.StructStorage.readonly x)
    end
  end

  module Builder = struct
    type array_t = Reader.builder_array_t
    type reader_array_t = Reader.array_t
    type pointer_t = rw MessageWrapper.Slice.t

    module Int64List = struct
      type struct_t = [`Int64List_c75fd268911bb1b9]
      type t = struct_t builder_t
      let has_values x =
        BA_.has_field x 0
      let values_get x =
        BA_.get_int64_list x 0
      let values_get_list x =
        Capnp.Array.to_list (values_get x)
      let values_get_array x =
        Capnp.Array.to_array (values_get x)
      let values_set x v =
        BA_.set_int64_list x 0 v
      let values_init x n =
        BA_.init_int64_list x 0 n
      let values_set_list x v =
        let builder = values_init x (List.length v) in
        let () = List.iteri (fun i a -> Capnp.Array.set builder i a) v in
        builder
      let values_set_array x v =
        let builder = values_init x (Array.length v) in
        let () = Array.iteri (fun i a -> Capnp.Array.set builder i a) v in
        builder
      let of_message x = BA_.get_root_struct ~data_words:0 ~pointer_words:1 x
      let to_message x = x.BA_.NM.StructStorage.data.MessageWrapper.Slice.msg
      let to_reader x = Some (RA_.StructStorage.readonly x)
      let init_root ?message_size () =
        BA_.alloc_root_struct ?message_size ~data_words:0 ~pointer_words:1 ()
      let init_pointer ptr =
        BA_.init_struct_pointer ptr ~data_words:0 ~pointer_words:1
    end
  end

  module Client = struct
  end

  module Service = struct
  end
  module MessageWrapper = MessageWrapper
end

module Make(M:Capnp.MessageSig.S) = MakeRPC(Capnp.RPC.None(M))
