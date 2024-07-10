/// Module: note_book
module note_book::notes {

    use sui::tx_context::{TxContext, Self};
    use sui::transfer::Self;
    use sui::object::{Self, UID};
    use std::string::String;
    use sui::event;
    

    public struct Notes has key {
        id: UID
    }

    public struct Note has key, store {
        id: UID,
        title: String,
        body: String,
        owner: address
    }

     // Event
     public struct Created<phantom T> has copy, drop {
        title: String,
        body: String,
        owner: address,
    }

    const ENotOwner: u64 = 0;

    #[allow(unused_function)]
    fun init(ctx: &mut TxContext) {
        let notes = Notes{
            id: sui::object::new(ctx),
        };
        transfer::share_object(notes)
    }

    public entry fun create_note(title: String, body: String, ctx: &mut TxContext) {
        let note = Note {
            id: object::new(ctx),
            title,
            body,
            owner: tx_context::sender(ctx)
        };
        transfer::transfer(note, tx_context::sender(ctx));

        event::emit(Created<Note>{
        title: title,
        body: body,
        owner: tx_context::sender(ctx),
        });
    }

    public entry fun delete_note(text: String, note: Note, _ctx: &mut TxContext) {
        let Note {id, title, body, owner} = note;
        assert!(tx_context::sender(_ctx) == owner, ENotOwner);
        sui::object::delete(id)
    }
}
