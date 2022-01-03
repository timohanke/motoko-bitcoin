import Blob "mo:base/Blob";
import Array "mo:base/Array";
import Nat32 "mo:base/Nat32";
import Nat8 "mo:base/Nat8";
import Buffer "mo:base/Buffer";
import Iter "mo:base/Iter";
import Debug "mo:base/Debug";

module {
    public class ChainSegment<T>(obj : T, base : Nat, n : Nat, eqT : (T,T) -> Bool) {
        public let sequence = Buffer.Buffer<T>(n);
        sequence.add(obj);

        public func len() : Nat { sequence.size() };
        public func add(x : T) : () { sequence.add(x) };

        public func base_pos() : Nat { base };
        public func tip_pos() : Nat { base + sequence.size() - 1 };
        //public func obj_at_inner_pos(i : Nat) : T { sequence.get(i) };
        public func obj_at_pos(pos : Nat) : T { sequence.get(pos - base) };
        public func obj_at_tip() : T { sequence.get(sequence.size() - 1) };   
        public func head_from_pos(pos : Nat) : ChainSegment<T> {
            // head includes pos
            let head = ChainSegment<T>(obj_at_pos(pos), pos, tip_pos() - pos + 1 : Nat, eqT);
            for (i in Iter.range(pos, tip_pos())) {
                head.add(obj_at_pos(i));
            };
            head
        };
        public func roll_back_to_pos(pos : Nat) {
            // pos becomes the new tip_pos
            for (i in Iter.range(1, tip_pos()-pos)) {
                ignore sequence.removeLast();
            };            
        };
        public func extend_by(segment : ChainSegment<T>) {
            if (not eqT(obj_at_tip(), segment.obj_at_pos(0))) {
                Debug.trap("extension segment does not match");
            };
            if (tip_pos() != segment.base_pos()) {
                Debug.trap("extension positions do not match");
            };
            ignore sequence.removeLast();
            sequence.append(segment.sequence);
        };
        public func isObj(pos : Nat, obj : T) : Bool {
            eqT(obj_at_pos(pos), obj) // equality needs to be defined for T
        };
    };
};
