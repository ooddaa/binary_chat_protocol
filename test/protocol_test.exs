defmodule Chat.ProtocolTest do
  use ExUnit.Case

  alias Chat.Protocol 
  alias Chat.Messages.{Broadcast, Register}

  describe "decode_message/1" do
    test "can decode register messages" do
      username = "oda"
      binary = <<0x01, 0x00, 0x03, username::binary, "rest">>
      assert {:ok, msg, rest} = Protocol.decode_message(binary)
      assert msg == %Register{ username: username }
      assert rest == "rest"

      assert Chat.Protocol.decode_message(<<0x01, 0x00>>)== :incomplete 
    end

    test "can decode broadcast messages" do
      username = "oda"
      contents = "some funky stuff"
      binary = <<0x02, 0x00, 0x03, username::binary, 0x00, String.length(contents), contents::binary, "rest">>
      assert {:ok, msg, rest} = Protocol.decode_message(binary)
      assert msg == %Broadcast{ username: username, contents: contents }
      assert rest == "rest"

      assert Chat.Protocol.decode_message(<<0x02, 0x00>>) == :incomplete 
    end

    test "returns :incomplete for empty data" do
      assert Chat.Protocol.decode_message("") == :incomplete
    end

    test "returns :error for unknown message types" do
      assert Chat.Protocol.decode_message(<<0x03, 0x00>>) == :error
    end
  end
end
