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
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, WinAPI.Winsock2, Vcl.StdCtrls, S7Edit,
  Sub7.Viewer.VCL.Button, Sub7.Viewer.VCL.SubSevenForm, WinApi.MMSystem,
  Sub7.Viewer.VCL.CaptionBar, S7Panel, S7StatusBar, VirtualTrees,
  Vcl.Imaging.pngimage, Vcl.Menus, S7PopupMenu, Generics.Collections;

type
  TClient = class;

  TTreeData = record
    Client        : TClient;
    RemoteAddress : String;
  end;
  PTreeData = ^TTreeData;

  TClient = class(TThread)
  private
    FClient : TSocket;
  protected
    {@M}
    procedure Execute(); override;
  public
    {@C}
    constructor Create(const AClient : TSocket); overload;

    {@M}
    procedure Close();

    {@G}
    property Client : TSocket read FClient;
  end;

  TClientHandler = class(TThread)
  private
    FServer : TSocket;
  protected
    {@M}
    procedure Execute(); override;
  public
    {@C}
    constructor Create(const AServer : TSocket); overload;
    destructor Destroy(); override;
  end;

  TFormMain = class(TForm)
    PanelCore: TS7Panel;
    S7CaptionBar1: TS7CaptionBar;
    S7Form1: TS7Form;
    VST: TVirtualStringTree;
    PanelFooter: TS7Panel;
    ButtonStop: TS7Button;
    ButtonStart: TS7Button;
    S7PopupMenu1: TS7PopupMenu;
    KickHim1: TMenuItem;
    N1: TMenuItem;
    KickAll1: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure FormResize(Sender: TObject);
    procedure ButtonStartClick(Sender: TObject);
    procedure ButtonStopClick(Sender: TObject);
    procedure VSTChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
    procedure VSTFocusChanged(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex);
    procedure VSTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
      Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
    procedure VSTGetNodeDataSize(Sender: TBaseVirtualTree;
      var NodeDataSize: Integer);
    procedure KickHim1Click(Sender: TObject);
    procedure KickAll1Click(Sender: TObject);
    procedure VSTResize(Sender: TObject);
  private
    FServer        : TSocket;
    FClientHandler : TClientHandler;

    {@M}
    procedure DoResize();
    procedure DoListen(const ABindAddress : String = ''; const AListenPort : Word = 2801);
    procedure DoStopListening();
    procedure CleanTerminateThread(const AThread : TThread);

    {@G}
    procedure SetServer(const AValue : TSocket);
  public
    {@M}
    procedure DeleteNode(const ASocket : TSocket);

    {@S}
    property Server : TSocket read FServer write SetServer;
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

(*

    TClient

*)

{ TClient.Execute }
procedure TClient.Execute();
var ACmd : byte;

  procedure OpenCloseCD(const AOpen : Boolean);
  var I              : Integer;
    ALogicalDrives : Integer;
    ALetter        : String;
    ACDAction      : String;
  begin
    ALogicalDrives := GetLogicalDrives();

    I := 0;
    for ALetter in ['a'..'z'] do begin
      if (ALogicalDrives and (1 shl I)) = 0 then begin
        Inc(I);

        continue;
      end;
      ///

      Inc(I);

      if GetDriveType(PChar(ALetter + ':')) <> DRIVE_CDROM then
        continue;

      if AOpen then
        ACDAction := 'open'
      else
        ACDAction := 'closed';

      mciSendString(PChar(Format('open cdaudio!%s: alias cdrom%s', [ALetter, ALetter])), nil, 0, 0);
      mciSendString(PChar(Format('set cdrom%s door %s wait', [ALetter, ACDAction])), nil, 0, 0);
    end;
  end;

begin
  try
    while not Terminated do begin
      if Winapi.Winsock2.recv(FClient, ACmd, SizeOf(Byte), 0) <= 0 then
        break;
      ///

      case ACmd of
        // Open CD-ROM Tray
        0 : OpenCloseCD(true);

        // Close CD-ROM Tray
        1 : OpenCloseCD(false);
      end;
    end;
  finally
    Synchronize(procedure begin
      FormMain.DeleteNode(FClient);
    end);

    ExitThread(0);
  end;
end;

{ TClient.Create }
constructor TClient.Create(const AClient : TSocket);
begin
  inherited Create(False);

  self.FreeOnTerminate := true;

  FClient := AClient;
end;

{ TClient.Close }
procedure TClient.Close();
begin
  if FClient <> INVALID_SOCKET then
    Winapi.Winsock2.closesocket(FClient);
end;

(*

    TClientHandler

*)

{ TClientHandler.Execute }
procedure TClientHandler.Execute();
var AClient        : TSocket;
    ARemoteAddress : String;
    ASockAddrIn    : TSockAddrIn;
    ALen           : Integer;
    pNode          : PVirtualNode;
    pData          : PTreeData;
begin
  try
    while not Terminated do begin
      ZeroMemory(@ASockAddrIn, SizeOf(TSockAddrIn));
      ALen := SizeOf(TSockAddrIn);

      AClient := WinAPI.WinSock2.accept(FServer, @ASockAddrIn, @ALen);
      if AClient = INVALID_SOCKET then
        raise Exception.Create('Accept failed. Server probably down.');

      ARemoteAddress := Format('%d.%d.%d.%d', [
        Ord(ASockAddrIn.sin_addr.S_un_b.s_b1),
        Ord(ASockAddrIn.sin_addr.S_un_b.s_b2),
        Ord(ASockAddrIn.sin_addr.S_un_b.s_b3),
        Ord(ASockAddrIn.sin_addr.S_un_b.s_b4)
      ]);

      Synchronize(procedure begin
        FormMain.VST.BeginUpdate();
        pNode := FormMain.VST.AddChild(nil);
      end);
      try
        pData := pNode.GetData;

        pData^.RemoteAddress := ARemoteAddress;
        pData^.Client        := TClient.Create(AClient);
      finally
        Synchronize(procedure begin
          FormMain.VST.EndUpdate();
        end);
      end;
    end;
  finally
    Synchronize(procedure begin
      FormMain.Server := INVALID_SOCKET;
    end);

    ///
    ExitThread(0);
  end;
end;

{ TClientHandler.Create }
constructor TClientHandler.Create(const AServer : TSocket);
begin
  inherited Create(False);
  ///

  self.FreeOnTerminate := true;

  self.FServer := AServer;
end;

{ TClientHandler.Destroy }
destructor TClientHandler.Destroy();
begin

  ///
  inherited Destroy();
end;

(*

    TFormMain

*)

{TFormMain.DoResize}
procedure TFormMain.DoResize();
begin
  ButtonStop.Left  := (PanelFooter.Width div 2) - ButtonStop.Width - 8;
  ButtonStart.Left := (PanelFooter.Width div 2) + 8;

  ButtonStart.Top  := (PanelFooter.Height div 2) - (ButtonStart.Height div 2);
  ButtonStop.Top := ButtonStart.Top;

  VST.BackgroundOffsetX := (VST.ClientWidth div 2) - (VST.Background.Width div 2);
  VST.BackgroundOffsetY := (VST.ClientHeight div 2) - (VST.Background.Height div 2);
end;

{ TFormMain.DoListen }
procedure TFormMain.ButtonStartClick(Sender: TObject);
var AListenPort : Integer;
    AValue : String;
begin
  AValue := '2801';

  if not InputQuery('Listen Port', 'Please enter a valid port (0..65535):', AValue) then
    Exit();

  if not TryStrToInt(AValue, AListenPort) then
    Exit();

  if (AListenPort > High(Word)) or (AListenPort < Low(Word)) then
    raise Exception.Create('TCP Port out of range (0..65535)');

  self.DoListen('', AListenPort);

  FClientHandler := TClientHandler.Create(FServer);
end;

procedure TFormMain.ButtonStopClick(Sender: TObject);
begin
  self.DoStopListening();
end;

procedure TFormMain.DoListen(const ABindAddress : String = ''; const AListenPort : Word = 2801);
var ASockAddrIn : TSockAddrIn;
    ASocket     : TSocket;
begin
  try
    ASocket := WinAPI.Winsock2.socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
    if ASocket = INVALID_SOCKET then
      Exception.Create('Could not create socket.');

    ZeroMemory(@ASockAddrIn, SizeOf(TSockAddrIn));

    ASockAddrIn.sin_port   := WinAPI.Winsock2.htons(AListenPort);
    ASockAddrIn.sin_family := AF_INET;

    if (ABindAddress = '0.0.0.0') or (ABindAddress = '') then
      ASockAddrIn.sin_addr.S_addr := INADDR_ANY
    else
      ASockAddrIn.sin_addr.S_addr := WinAPI.Winsock2.inet_addr(PAnsiChar(AnsiString(ABindAddress)));

    if WinAPI.Winsock2.bind(ASocket, TSockAddr(ASockAddrIn), SizeOf(TSockAddrIn)) = SOCKET_ERROR then
      raise Exception.Create('Could not bind socket.');

    if WinAPI.WinSock2.listen(ASocket, SOMAXCONN) = SOCKET_ERROR then
      raise Exception.Create('Could not listen on socket.');
  except
    on E: Exception do begin
      if (ASocket <> INVALID_SOCKET) then
        WinAPI.Winsock2.closesocket(ASocket);

      ///
      raise;
    end;
  end;

  if ASocket <> INVALID_SOCKET then
    self.SetServer(ASocket);
end;

{ TFormMain.DeleteNode }
procedure TFormMain.DeleteNode(const ASocket : TSocket);
var pNode : PVirtualNode;
    pData : PTreeData;
begin
  VST.BeginUpdate();
  try
    for pNode in VST.Nodes(true) do begin
      pData := pNode.GetData;
      if not Assigned(pData) then
        continue;

      if pData^.Client.Client = ASocket then begin
        WinAPI.Winsock2.closesocket(ASocket);

        VST.DeleteNode(pNode);

        break;
      end;
    end;
  finally
    VST.EndUpdate();
  end;
end;

{ TFormMain.CleanTerminateThread }
procedure TFormMain.CleanTerminateThread(const AThread : TThread);
var AExitCode : Cardinal;
begin
  if Assigned(AThread) then begin
    GetExitCodeThread(AThread.Handle, AExitCode);
    if (AExitCode = STILL_ACTIVE) then begin
      AThread.Terminate();
      AThread.WaitFor();
    end;
  end;
end;

{ TFormMain.DoStopListening }
procedure TFormMain.DoStopListening();
var pNode : PVirtualNode;
    pData : PTreeData;
begin
  // Close Clients

  for pNode in VST.Nodes(True) do begin
    pData := pNode.GetData;
    if not Assigned(pData) then
      continue;

    pData^.Client.Close();

    CleanTerminateThread(pData^.Client);
    pData^.Client := nil;
  end;

  // Close Server

  if FServer <> INVALID_SOCKET then begin
    WinAPI.Winsock2.closesocket(FServer);

    self.SetServer(INVALID_SOCKET);
  end;

  CleanTerminateThread(FClientHandler);
  FClientHandler := nil;
end;

{ TFormMain.FormCreate }
procedure TFormMain.FormCreate(Sender: TObject);
begin
  self.SetServer(INVALID_SOCKET);

  self.S7CaptionBar1.Caption := self.Caption;
  self.DoResize();

  FClientHandler := nil;
end;

procedure TFormMain.SetServer(const AValue : TSocket);
begin
  self.ButtonStop.Enabled  := AValue <> INVALID_SOCKET;
  self.ButtonStart.Enabled := not self.ButtonStop.Enabled;

  FServer := AValue;
end;

procedure TFormMain.KickAll1Click(Sender: TObject);
var pNode : PVirtualNode;
    pData : PTreeData;
begin
  for pNode in VST.Nodes do begin
    pData := pNode.GetData;
    if not Assigned(pData) then
      continue;

    if not Assigned(pData^.Client) then
      continue;

    pData^.Client.Close();
  end;
end;

procedure TFormMain.VSTChange(Sender: TBaseVirtualTree; Node: PVirtualNode);
begin
  VST.Refresh;
end;

procedure TFormMain.VSTFocusChanged(Sender: TBaseVirtualTree;
  Node: PVirtualNode; Column: TColumnIndex);
begin
  VST.Refresh;
end;

procedure TFormMain.VSTGetNodeDataSize(Sender: TBaseVirtualTree;
  var NodeDataSize: Integer);
begin
  NodeDataSize := SizeOf(TTreeData);
end;

procedure TFormMain.VSTGetText(Sender: TBaseVirtualTree; Node: PVirtualNode;
  Column: TColumnIndex; TextType: TVSTTextType; var CellText: string);
var pData : PTreeData;
begin
  pData := Node.GetData;
  if not Assigned(pData) then
    Exit();

  case Column of
    0 : CellText := pData^.RemoteAddress;
    1 : CellText := IntToStr(pData^.Client.Client);
  end;
end;

procedure TFormMain.VSTResize(Sender: TObject);
begin
  self.DoResize();
end;

procedure TFormMain.FormResize(Sender: TObject);
begin
  self.DoResize();
end;

procedure TFormMain.KickHim1Click(Sender: TObject);
var pData : PTreeData;
begin
  if VST.FocusedNode = nil then
    Exit();

  pData := VST.FocusedNode.GetData;
  if not Assigned(pData) then
    Exit();

  pData^.Client.Close();
end;

var __WSAData : TWSAData;

initialization
  WSAStartup($0202, __WSAData);

finalization
  WSACleanup();

end.
