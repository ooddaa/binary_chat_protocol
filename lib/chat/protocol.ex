defmodule Chat.Protocol do
  alias Chat.Messages.{Broadcast, Register}

  @type message() :: Broadcast.t() | Register.t()

  @spec decode_message(binary()) :: {:ok, message(), binary()} | :error | :incomplete
  def decode_message(<<0x01, rest::binary>>), do: decode_register(rest)
  def decode_message(<<0x02, rest::binary>>), do: decode_broadcast(rest)
  def decode_message(<<>>), do: :incomplete
  def decode_message(<<_::binary>>), do: :error

  defp decode_register(<<username_len::16, username::binary-size(username_len), rest::binary>>), do: {:ok, %Register{ username: username }, rest }
  
  defp decode_register(<<_::binary>>), do: :incomplete

  defp decode_broadcast(<<username_len::16, username::binary-size(username_len), contents_len::16, contents::size(contents_len)-binary, rest::binary>>), do: {:ok, %Broadcast{ username: username, contents: contents }, rest }
  
  defp decode_broadcast(<<_::binary>>), do: :incomplete
end
