@0x8841c9734eabf620;

struct MerkleTree {
  hash @0: Int64;  # Stores the hash value

  union {
    leaf  @1: Void;
    internal @2: List(MerkleTree);
  }
}
