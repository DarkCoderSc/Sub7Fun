{******************************************************************************}
{                                                                              }
{         ____             _     ____          _           ____                }
{        |  _ \  __ _ _ __| | __/ ___|___   __| | ___ _ __/ ___|  ___          }
{        | | | |/ _` | '__| |/ / |   / _ \ / _` |/ _ \ '__\___ \ / __|         }
{        | |_| | (_| | |  |   <| |__| (_) | (_| |  __/ |   ___) | (__          }
{        |____/ \__,_|_|  |_|\_\\____\___/ \__,_|\___|_|  |____/ \___|         }
{                                                                              }
{                                                                              }
{                   Author: DarkCoderSc (Jean-Pierre LESUEUR)                  }
{                   https://www.twitter.com/                                   }
{                   https://github.com/darkcodersc                             }
{                   License: Apache License 2.0                                }
{                                                                              }
{                                                                              }
{  Disclaimer:                                                                 }
{  -----------                                                                 }
{    We are doing our best to prepare the content of this app and/or code.     }
{    However, The author cannot warranty the expressions and suggestions       }
{    of the contents, as well as its accuracy. In addition, to the extent      }
{    permitted by the law, author shall not be responsible for any losses      }
{    and/or damages due to the usage of the information on our app and/or      }
{    code.                                                                     }
{                                                                              }
{    By using our app and/or code, you hereby consent to our disclaimer        }
{    and agree to its terms.                                                   }
{                                                                              }
{    Any links contained in our app may lead to external sites are provided    }
{    for convenience only.                                                     }
{    Any information or statements that appeared in these sites or app or      }
{    files are not sponsored, endorsed, or otherwise approved by the author.   }
{    For these external sites, the author cannot be held liable for the        }
{    availability of, or the content located on or through it.                 }
{    Plus, any losses or damages occurred from using these contents or the     }
{    internet generally.                                                       }
{                                                                              }
{                                                                              }
{                                                                              }
{                                                                              }
{******************************************************************************}

unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Sub7.Viewer.VCL.CaptionBar,
  Sub7.Viewer.VCL.SubSevenForm, S7Panel, S7StatusBar, Sub7.Viewer.VCL.Button,
  S7GroupBox, Vcl.Imaging.pngimage, Vcl.ExtCtrls, Vcl.StdCtrls, S7ComboBox,
  S7Edit, WinApi.Winsock2;

type
  TFormMain = class(TForm)
    S7Form1: TS7Form;
    S7CaptionBar1: TS7CaptionBar;
    PanelCore: TS7Panel;
    ButtonOpen: TS7Button;
    ButtonClose: TS7Button;
    S7Panel2: TS7Panel;
    LabelRemotePort: TLabel;
    EditRemotePort: TS7Edit;
    LabelRemoteAddress: TLabel;
    EditRemoteAddress: TS7Edit;
    ButtonConnect: TS7Button;
    TimerKeepAlive: TTimer;
    Label1: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure ButtonConnectClick(Sender: TObject);
    procedure ButtonConnectValueChanged(Sender: TObject; ANewValue: Integer);
    procedure TimerKeepAliveTimer(Sender: TObject);
    procedure Label1Click(Sender: TObject);
    procedure ButtonOpenClick(Sender: TObject);
    procedure ButtonCloseClick(Sender: TObject);
  private
    FClient : TSocket;

    {@M}
    procedure DoResize();
    procedure DoDisconnect();

    procedure SetClient(const AValue : TSocket);
    procedure DoConnect(const ARemoteAddress : String = '127.0.0.1'; const ARemotePort : Word = 2801);

    procedure SendCommand(const ACommand : Byte = 99 {KeepAlive});
  public
    {@S}
    property Client : TSocket read FClient write SetClient;
  end;

var
  FormMain: TFormMain;

implementation

uses Winapi.ShellAPI;

{$R *.dfm}

procedure TFormMain.ButtonCloseClick(Sender: TObject);
begin
  self.SendCommand(1);
end;

procedure TFormMain.ButtonConnectClick(Sender: TObject);
begin
  case TS7Button(Sender).Value of
    0 : begin
      self.DoConnect(
        self.EditRemoteAddress.Text,
        StrToInt(self.EditRemotePort.Text)
      );
    end;

    1 : begin
      self.DoDisconnect();
    end;
  end;
end;

procedure TFormMain.SetClient(const AValue : TSocket);
begin
  if AValue <> INVALID_SOCKET then
    self.ButtonConnect.Value := 1
  else
    self.ButtonConnect.Value := 0;

  FClient := AValue;
end;

procedure TFormMain.TimerKeepAliveTimer(Sender: TObject);
begin
  // I'm lazy to create a specific thread just for that ;)
  if FClient <> INVALID_SOCKET then begin
    self.SendCommand();
  end;
end;

procedure TFormMain.ButtonConnectValueChanged(Sender: TObject;
  ANewValue: Integer);
var AText : String;
begin
  case ANewValue of
    0 : begin
      AText := 'connect';
    end;

    1 : begin
      AText := 'disconnect';
    end;
  end;

  self.EditRemotePort.Enabled := ANewValue = 0;
  self.EditRemoteAddress.Enabled := self.EditRemotePort.Enabled;

  self.ButtonOpen.Enabled  := ANewValue = 1;
  self.ButtonClose.Enabled := self.ButtonOpen.Enabled;

  TS7Button(Sender).Caption := AText;
end;

procedure TFormMain.ButtonOpenClick(Sender: TObject);
begin
  self.SendCommand(0);
end;

procedure TFormMain.SendCommand(const ACommand : Byte = 99 {KeepAlive});
begin
  if Winapi.Winsock2.send(FClient, ACommand, SizeOf(Byte), 0) <= 0 then
    self.DoDisconnect();
end;

procedure TFormMain.DoConnect(const ARemoteAddress : String = '127.0.0.1'; const ARemotePort : Word = 2801);
var AHostEnt    : PHostEnt;
    ASockAddrIn : TSockAddrIn;
    ASocket     : TSocket;
begin
  ASocket := WinAPI.Winsock2.socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
  if ASocket = INVALID_SOCKET then
    raise Exception.Create('Could not create socket.');

  ZeroMemory(@ASockAddrIn, SizeOf(TSockAddrIn));

  ASockAddrIn.sin_port        := WinAPI.Winsock2.htons(ARemotePort);
  ASockAddrIn.sin_family      := AF_INET;
  ASockAddrIn.sin_addr.S_addr := WinAPI.Winsock2.inet_addr(PAnsiChar(AnsiString(ARemoteAddress)));

  if ASockAddrIn.sin_addr.S_addr = INADDR_NONE then begin
    AHostEnt := GetHostByName(PAnsiChar(AnsiString(ARemoteAddress)));
    if AHostEnt <> nil then
      ASockAddrIn.sin_addr.S_addr := Integer(Pointer(AHostEnt^.h_addr^)^);
  end;

  if (WinAPI.Winsock2.connect(ASocket, TSockAddr(ASockAddrIn), SizeOf(TSockAddrIn)) = SOCKET_ERROR) then
    raise Exception.Create('Could not connect to remote server.');

  ///
  self.SetClient(ASocket);
end;

procedure TFormMain.DoDisconnect();
begin
  if FClient <> INVALID_SOCKET then begin
    WinAPI.Winsock2.closesocket(FClient);

    self.SetClient(INVALID_SOCKET);
  end;
end;

procedure TFormMain.DoResize();
begin
  ButtonOpen.Left  := (PanelCore.Width div 2) - ButtonOpen.Width - 8;
  ButtonClose.Left := (PanelCore.Width div 2) + 8;

  ButtonOpen.Top  := (PanelCore.Height div 2) - (ButtonOpen.Height div 2);
  ButtonClose.Top := ButtonOpen.Top;
end;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  self.S7CaptionBar1.Caption := self.Caption;

  self.DoResize();
end;

procedure TFormMain.FormResize(Sender: TObject);
begin
  self.DoResize();
end;

procedure TFormMain.Label1Click(Sender: TObject);
begin
  ShellExecute(0, 'open', 'https://github.com/darkcodersc', nil, nil, SW_SHOW);
end;

var __WSAData : TWSAData;

initialization
  WSAStartup($0202, __WSAData);

finalization
  WSACleanup();

end.
