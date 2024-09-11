defmodule Chat.Messages.Broadcast do
  defstruct username: nil, contents: nil

  @type t :: %__MODULE__{
    username: binary(),
    contents: binary()
  }
end
