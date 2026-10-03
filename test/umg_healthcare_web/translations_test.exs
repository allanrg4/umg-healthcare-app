defmodule UmgHealthcareWeb.TranslationsTest do
  use ExUnit.Case, async: true

  import UmgHealthcareWeb.CoreComponents, only: [translate_error: 1]

  # Tests run in English; here we switch to Spanish, the app's default language.
  setup do
    Gettext.put_locale(UmgHealthcareWeb.Gettext, "es")
    :ok
  end

  test "simple validation errors are translated" do
    assert translate_error({"can't be blank", []}) == "no puede estar vacío"
    assert translate_error({"has already been taken", []}) == "ya está en uso"
    assert translate_error({"is used by a prescription", []}) == "la usa una receta"
  end

  test "errors with counts use the right plural" do
    error = "should be at least %{count} character(s)"

    assert translate_error({error, [count: 12]}) == "debe tener al menos 12 caracteres"
    assert translate_error({error, [count: 1]}) == "debe tener al menos 1 carácter"
  end

  test "errors with numbers keep the value" do
    assert translate_error({"must be greater than %{number}", [number: 0]}) ==
             "debe ser mayor que 0"
  end
end
