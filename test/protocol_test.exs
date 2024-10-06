defmodule Chat.ProtocolTest do
  use ExUnit.Case

  alias Chat.Protocol 
  alias Chat.Messages.{Broadcast, Register}

  describe "decode_message/1" do
    test "can decode Register messages" do
      username = "oda"
      binary = <<0x01, 0x00, 0x03, username::binary, "rest">>
      assert {:ok, msg, rest} = Protocol.decode_message(binary)
      assert msg == %Register{ username: username }
      assert rest == "rest"

      assert Protocol.decode_message(<<0x01, 0x00>>)== {:error, :incomplete, {{:decode_register, 1}, <<0x00>>}} 
    end

    test "can decode Broadcast messages" do
      username = "oda"
      contents = "some funky stuff"
      binary = <<0x02, 0x00, 0x03, username::binary, 0x00, String.length(contents), contents::binary, "rest">>
      assert {:ok, msg, rest} = Protocol.decode_message(binary)
      assert msg == %Broadcast{ username: username, contents: contents }
      assert rest == "rest"

      assert Protocol.decode_message(<<0x02, 0x00>>) == {:error, :incomplete, {{:decode_broadcast, 1}, <<0x00>>}} 
    end

    test "returns :incomplete for empty data" do
      assert Protocol.decode_message("") == {:error, :incomplete, {{:decode_message, 1}, ""}}
    end

    test "returns :not_implemented for unknown message types" do
      msg = <<0x03, 0x00>>
      assert Protocol.decode_message(msg) == {:error, :not_implemented, {{:decode_message, 1}, msg}}
    end
  end
  
  describe "encode_message/1" do
    test "can encode Register messages" do
      msg = %Register{ username: "oda" }
      assert Protocol.encode_message(msg) == <<0x01, 0x00, 0x03, "oda">> 
    end
    
    test "can encode Broadcast messages" do
      msg = %Broadcast{ username: "oda", contents: "elixir rocks" }
      assert Protocol.encode_message(msg) == <<0x02, 0x00, 0x03, "oda", 0x00, 0x0c, "elixir rocks">> 
    end
    
    test "returns :incomplete for empty data" do
      register_msg = %Register{ username: "" }
      assert Protocol.encode_message(register_msg) == {:error, :incomplete, {{:encode_register, 1}, register_msg}}
      broadcast_msg = %Broadcast{ username: "", contents: "" }
      assert Protocol.encode_message(broadcast_msg) == {:error, :incomplete, {{:encode_broadcast, 1}, broadcast_msg}}
      broadcast_msg = %Broadcast{ username: "oda", contents: "" }
      assert Protocol.encode_message(broadcast_msg) == {:error, :incomplete, {{:encode_broadcast, 1}, broadcast_msg}}
      broadcast_msg = %Broadcast{ username: "", contents: "contents" }
      assert Protocol.encode_message(broadcast_msg) == {:error, :incomplete, {{:encode_broadcast, 1}, broadcast_msg}}
    end

    test "returns :not_implemented for unknown message types" do
      msg = ""
      assert Protocol.encode_message(msg) == {:error, :not_implemented, {{:encode_message, 1}, msg}}
    end
  end
  
  describe "encode_message_io/1" do
    test "can encode Register messages into iodata" do
      msg = %Register{ username: "oda" }
      iodata = Protocol.encode_message_io(msg) 
        assert iodata == [1, <<0x00, 0x03, "oda">>] 
        assert IO.iodata_to_binary(iodata) == <<0x01, 0x00, 0x03, "oda">> 
    end
    
    test "can encode Broadcast messages into iodata" do
      msg = %Broadcast{ username: "oda", contents: "elixir rocks" }
      iodata = Protocol.encode_message_io(msg) 
      assert iodata == [2, <<0x00, 0x03, "oda">>, <<0x00, 0x0c, "elixir rocks">>]
      assert IO.iodata_to_binary(iodata) == <<0x02, 0x00, 0x03, "oda", 0x00, 0x0c, "elixir rocks">>
    end
  end
end
