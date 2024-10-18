open System
open System.Net
open System.Net.Http
open System.Net.Mime
open System.Text
open System.Text.Json
open System.Text.Json.Serialization

type RequestContent = { Token: string }

type CheckinRecord = { Change: string; Balance: string }

type ResponseContent =
    { Code: int
      Points: double
      Message: string
      [<JsonPropertyName("list")>]
      Records: list<CheckinRecord> }

let getGLadosCookie =
    match Environment.GetEnvironmentVariable "GLADOS_COOKIE" with
    | null -> None
    | value -> Some(value)


let jsonOption =
    let option = new JsonSerializerOptions()
    option.PropertyNamingPolicy <- JsonNamingPolicy.SnakeCaseLower

    option

let parseResponse (content: string) : option<ResponseContent> =
    try
        Some(JsonSerializer.Deserialize<ResponseContent>(content, jsonOption))
    with e ->
        printfn "Json error: %s" e.Message
        None


let checkin =
    let client = new HttpClient()

    let request = new HttpRequestMessage()
    request.RequestUri <- Uri "https://glados.network/api/user/checkin"
    request.Method <- HttpMethod.Post
    request.Content <- new StringContent("""{"token": "glados.one"}""", Encoding.UTF8, MediaTypeNames.Application.Json)

    match getGLadosCookie with
    | None -> printfn "Failed to get cookie!"
    | Some(cookie) -> request.Headers.Add("Cookie", cookie)


    request.Headers.Add(
        "User-Agent",
        "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:130.0) Gecko/20100101 Firefox/130.0"
    )

    async {
        let! response = request |> client.SendAsync |> Async.AwaitTask

        match response.StatusCode with
        | HttpStatusCode.OK ->
            let! content = response.Content.ReadAsStringAsync() |> Async.AwaitTask

            match content |> parseResponse with
            | None -> printfn "Failed to checkin due to JsonSerializer error"
            | Some(value) ->
                printfn $"{value.Message}"
                printfn $"The points now is {value.Records.Head.Balance}"
        | _ -> printfn "Failed to check in due to network error!"

        client.Dispose()
    }

checkin |> Async.RunSynchronously
