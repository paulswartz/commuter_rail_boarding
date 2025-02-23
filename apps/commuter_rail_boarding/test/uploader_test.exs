defmodule UploaderTest do
  @moduledoc false
  use ExUnit.Case, async: true

  import Uploader

  describe "upload/1" do
    test "uploads a binary" do
      assert :ok = upload("filename", "binary")
      # message received from Uploader.Mock
      assert_received {:upload, "filename", "binary"}
    end
  end
end
