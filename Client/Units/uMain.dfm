object FormMain: TFormMain
  Left = 0
  Top = 0
  BorderStyle = bsNone
  BorderWidth = 2
  Caption = 'Sub7Fun - Client'
  ClientHeight = 172
  ClientWidth = 304
  Color = clGray
  DoubleBuffered = True
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Arial'
  Font.Style = []
  Position = poScreenCenter
  OnCreate = FormCreate
  OnResize = FormResize
  TextHeight = 14
  object S7CaptionBar1: TS7CaptionBar
    Left = 0
    Top = 0
    Width = 304
    Height = 19
    Caption = ''
    BorderIcons = [biSystemMenu, biMinimize]
    Dockable = False
    Transparent = False
    Collapsible = True
    TextCenter = False
    MainColor = 16744576
    SecondaryColor = clBlack
    Align = alTop
    ExplicitWidth = 419
  end
  object PanelCore: TS7Panel
    Left = 0
    Top = 60
    Width = 304
    Height = 112
    BorderTop = 0
    BorderLeft = 0
    BorderRight = 0
    BorderBottom = 0
    Color = clBlack
    BorderColor = clBlack
    Align = alClient
    Caption = 'PanelCore'
    TabOrder = 0
    object ButtonOpen: TS7Button
      Left = 20
      Top = 32
      Width = 120
      Height = 30
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      Enabled = False
      TextAlign = taCenter
      Down = False
      Chevron = False
      Caption = 'open CD-ROM'
      Value = 0
      OnClick = ButtonOpenClick
      Busy = False
    end
    object ButtonClose: TS7Button
      Left = 162
      Top = 32
      Width = 120
      Height = 30
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWindowText
      Font.Height = -12
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      Enabled = False
      TextAlign = taCenter
      Down = False
      Chevron = False
      Caption = 'close CD-ROM'
      Value = 0
      OnClick = ButtonCloseClick
      Busy = False
    end
    object Label1: TLabel
      AlignWithMargins = True
      Left = 3
      Top = 96
      Width = 298
      Height = 13
      Cursor = crHandPoint
      Align = alBottom
      Alignment = taCenter
      Caption = '@darkcodersc'
      Color = clBlack
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clGray
      Font.Height = -11
      Font.Name = 'Courier'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      OnClick = Label1Click
      ExplicitWidth = 96
    end
  end
  object S7Panel2: TS7Panel
    Left = 0
    Top = 19
    Width = 304
    Height = 41
    BorderTop = 0
    BorderLeft = 0
    BorderRight = 0
    BorderBottom = 0
    Color = 8404992
    BorderColor = clBlack
    Align = alTop
    Caption = 'S7Panel2'
    TabOrder = 1
    object LabelRemotePort: TLabel
      AlignWithMargins = True
      Left = 146
      Top = 15
      Width = 25
      Height = 23
      Margins.Left = 6
      Margins.Top = 15
      Align = alLeft
      Caption = 'Port :'
      Color = 8404992
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      Transparent = True
      ExplicitHeight = 14
    end
    object LabelRemoteAddress: TLabel
      AlignWithMargins = True
      Left = 8
      Top = 15
      Width = 55
      Height = 23
      Margins.Left = 8
      Margins.Top = 15
      Align = alLeft
      Caption = 'destination:'
      Color = 8404992
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'Arial'
      Font.Style = []
      ParentColor = False
      ParentFont = False
      Transparent = True
      ExplicitHeight = 14
    end
    object ButtonConnect: TS7Button
      AlignWithMargins = True
      Left = 225
      Top = 9
      Width = 71
      Height = 23
      Hint = 'connect to server'
      Margins.Left = 4
      Margins.Top = 9
      Margins.Right = 4
      Margins.Bottom = 9
      Align = alLeft
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = []
      Enabled = True
      TextAlign = taCenter
      Down = False
      Chevron = False
      Caption = 'connect'
      Value = 0
      OnClick = ButtonConnectClick
      OnValueChanged = ButtonConnectValueChanged
      Busy = False
      ExplicitLeft = 278
      ExplicitHeight = 24
    end
    object EditRemotePort: TS7Edit
      AlignWithMargins = True
      Left = 177
      Top = 10
      Width = 40
      Height = 20
      Hint = 'remote server port'
      Margins.Top = 10
      Margins.Right = 4
      Margins.Bottom = 11
      Align = alLeft
      AutoSize = False
      Color = clBlack
      Enabled = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -13
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      NumbersOnly = True
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 0
      Text = '2801'
      AlternativeTheme = False
      Status = csNormal
      Validators = []
    end
    object EditRemoteAddress: TS7Edit
      AlignWithMargins = True
      Left = 66
      Top = 10
      Width = 74
      Height = 21
      Margins.Left = 0
      Margins.Top = 10
      Margins.Right = 0
      Margins.Bottom = 10
      Align = alLeft
      AutoSize = False
      Color = clBlack
      Enabled = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -11
      Font.Name = 'MS Sans Serif'
      Font.Style = [fsBold]
      ParentFont = False
      ParentShowHint = False
      ShowHint = True
      TabOrder = 1
      Text = '127.0.0.1'
      AlternativeTheme = False
      Status = csNormal
      Validators = []
    end
  end
  object S7Form1: TS7Form
    Resizable = False
    ShowBorder = True
    Color = clGray
    Left = 240
    Top = 176
  end
  object TimerKeepAlive: TTimer
    OnTimer = TimerKeepAliveTimer
    Left = 240
    Top = 108
  end
end
