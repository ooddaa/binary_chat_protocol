defmodule Chat.Messages.Register do
  defstruct username: nil

  @type t :: %__MODULE__{
    username: binary(),
  }
end
