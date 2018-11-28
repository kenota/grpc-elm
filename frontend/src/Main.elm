module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Request.HelloWorldService exposing (sayHello)
import Html.Events exposing (onClick, onInput)
import Data.GreetingType exposing (GreetingType(..))
import Data.ElmTalkRequest exposing (ElmTalkRequest)
import Data.ElmTalkResponse exposing (ElmTalkResponse)
import Http exposing (send,  Error(..) )

main : Program () Model Msg
main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { value : Int
    , name:  String
    , greetingType: GreetingType
    , response: String
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model 0 "" GREETINGTYPEUNSPECIFIED "", Cmd.none )



-- UPDATE


type Msg
    = Init
    | LoadHello (Result Http.Error ElmTalkResponse)
    | SendRequest 
    | UpdateName String 
    | Select GreetingType


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Init ->
            ( model, Cmd.none )
        LoadHello (Err resp) ->
            (updateModelWithError resp model, Cmd.none)
        LoadHello (Ok resp) ->
            (updateModelWithReply resp model, Cmd.none)
        SendRequest ->
            (model, sendApiRequest model)
        UpdateName name ->
            ({model | name = name}, Cmd.none)
        Select greeting ->
            ({model | greetingType = greeting}, Cmd.none)


-- Helpers

updateModelWithReply : ElmTalkResponse -> Model -> Model 
updateModelWithReply resp model =
    case resp.greeting of
        Nothing -> 
            {model | response = "Nothing from server "}
        Just text ->
            {model | response = "Server says: " ++ text}

updateModelWithError : Http.Error -> Model -> Model
updateModelWithError err model = 
    case err of
        BadPayload text something -> { model | response = "bad payload: " ++ text}
        NetworkError  -> { model | response = "network error " }
        BadStatus r ->  { model | response = "bad status " ++ r.status.message}
        _ -> {model | response = "some other error"}


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    div []    
    [ input [ type_ "text", placeholder "Name", value model.name, onInput UpdateName] []
    , br [] [] 
    , br [] []

    , fieldset [] 
        [ label []
            [ input [ type_ "radio", onClick (Select ELMWAY), checked (model.greetingType == ELMWAY)] []
            , text "ELMWAY"
            ]
        , label []
            [ input [ type_ "radio", onClick (Select NORMAL), checked (model.greetingType == NORMAL)] []
            , text "NORMAL"
            ] 
        , label []
            [ input [ type_ "radio", onClick (Select GREETINGTYPEUNSPECIFIED), checked (model.greetingType == GREETINGTYPEUNSPECIFIED)] []
            , text "UNSPECIFIED"
            ]
        ]
    , br [] []
    , button [ onClick SendRequest ] [ text "call sayHello()" ]
    , br [][]
    , br [] []
    , div [] [ text model.response ]    
    ]




-- Api

-- sendRequest : Model -> Cmd Msg
-- sendRequest model = 
    -- Http.send (sayHello 
    -- { name = model.name
    -- , greetingType = model.greetingType
    -- }
sendApiRequest : Model -> Cmd Msg
sendApiRequest model =     
    sayHello  (ElmTalkRequest (Just model.name) (Just model.greetingType))
        |> Http.send LoadHello