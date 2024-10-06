defmodule Chat.Protocol do
  alias Chat.Messages.{Broadcast, Register}

  @type message() :: Broadcast.t() | Register.t()

  @spec encode_message(binary()) :: {:ok, message(), binary()} | {:error, :not_implemented, metadata()} | {:error, :incomplete, metadata()}
  def decode_message(<<0x01, rest::binary>>), do: decode_register(rest)
  def decode_message(<<0x02, rest::binary>>), do: decode_broadcast(rest)
  def decode_message(<<>>), do: {:error, :incomplete, {__ENV__.function, <<>>}}
  def decode_message(msg), do: {:error, :not_implemented, {__ENV__.function, msg}}

  defp decode_register(<<username_len::16, username::binary-size(username_len), rest::binary>>), do: {:ok, %Register{ username: username }, rest }
  
  defp decode_register(<<msg::binary>>), do: {:error, :incomplete, {__ENV__.function, msg}}

  defp decode_broadcast(<<username_len::16, username::binary-size(username_len), contents_len::16, contents::size(contents_len)-binary, rest::binary>>), do: {:ok, %Broadcast{ username: username, contents: contents }, rest }
  
  defp decode_broadcast(<<msg::binary>>), do: {:error, :incomplete, {__ENV__.function, msg}}

  @type metadata::{{atom(), non_neg_integer()}, any()} 
  @spec encode_message(message()) :: {:ok, binary()} | {:error, :not_implemented, metadata()} | {:error, :incomplete, metadata()}
  def encode_message(%Register{} = msg), do: encode_register(msg)
  def encode_message(%Broadcast{} = msg), do: encode_broadcast(msg)
  def encode_message(msg), do: {:error, :not_implemented, {__ENV__.function, msg}}

  defp encode_register(%Register{ username: username }) when is_binary(username) and byte_size(<<username::binary>>) > 1 do
    <<0x01, byte_size(username)::size(16), username::binary>>  
  end
  defp encode_register(msg), do: {:error, :incomplete, {__ENV__.function, msg}}

  defp encode_broadcast(%Broadcast{ username: username, contents: contents}) when is_binary(username) and byte_size(<<username::binary>>) > 1 and is_binary(contents) and byte_size(<<contents::binary>>) > 1 do
    <<0x02, byte_size(username)::size(16), username::binary, byte_size(contents)::size(16), contents::binary>>  
  end
  defp encode_broadcast(msg), do: {:error, :incomplete, {__ENV__.function, msg}}
end
