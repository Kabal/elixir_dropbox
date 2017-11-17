defmodule ElixirDropbox do
  @moduledoc """
  ElixirDropbox is a wrapper for Dropbox API V2
  """
  use HTTPoison.Base

  @type response :: {any}

  @base_url Application.get_env(:elixir_dropbox, :base_url)

  def post(client, url, body \\ "") do
    headers = json_headers()
    post_request(client, "#{@base_url}#{url}", body, headers)
  end

  def post_url(client, base_url, url, body \\ "") do
    headers = json_headers()
    post_request(client, "#{base_url}#{url}", body, headers)
  end

  @spec upload_response(HTTPoison.Response.t) :: response
  def upload_response(%HTTPoison.Response{status_code: 200, body: body}), do: Poison.decode!(body)
  def upload_response(%HTTPoison.Response{status_code: status_code, body: body }) do
    cond do
    status_code in 400..599 ->
      {{:status_code, status_code}, JSON.decode(body)}
    end
  end

  @spec download_response(HTTPoison.Response.t) :: response
  def download_response(%HTTPoison.Response{status_code: 200, body: body, headers: headers}), do: %{body: body, headers: headers}
  def download_response(%HTTPoison.Response{status_code: status_code, body: body }) do
    cond do
    status_code in 400..599 ->
      {{:status_code, status_code}, JSON.decode(body)}
    end
  end

  def post_request(client, url, body, headers) do
    headers = Map.merge(headers, headers(client))
    HTTPoison.post!(url, body, headers, [connect_timeout: 1000000, recv_timeout: 1000000, timeout: 1000000]) |> upload_response
  end

  def upload_request(client, base_url, url, data, headers) do
    post_request(client, "#{base_url}#{url}", {:file, data}, headers)
  end

  def download_request(client, base_url, url, data, headers) do
    headers = Map.merge(headers, headers(client))
    HTTPoison.post!("#{@upload_url}#{url}", data, headers, [connect_timeout: 1000000, recv_timeout: 1000000, timeout: 1000000]) |> download_response  
  end

  def headers(client) do
    %{ "Authorization" => "Bearer #{client.access_token}" }
  end
end
