program layoutkay;

{$AppType GUI}

uses
  windows, Messages, ShellApi, SysUtils, Clipbrd;

const
  Ico_Message = WM_USER;
  CharEngRus: array[32..126] of Byte =
  ($20, $21, $DD, $B9, $3B, $25, $3F, $FD, $28, $29, $2A, {*}
  $2B, $E1, $2D, $FE, $2E, $30, $31, $32, $33, $34, $35, {5}
  $36, $37, $37, $38, $39, $C6, $E6, $C1, $3D, $DE, $2C, $22, {@}
  $D4, $C8, $D1, $C2, $D3, $C0, $CF, $D0, $D8, $CE, $CB, {K}
  $C4, $DC, $D2, $D9, $C7, $C9, $CA, $DB, $C5, $C3, $CC, {V}
  $D6, $D7, $CD, $DF, $F5, $5C, $FA, $3A, $5F, $B8, $F4, {a}
  $E8, $F1, $E2, $F3, $E0, $EF, $F0, $F8, $EE, $EB, $E4, {l}
  $FC, $F2, $F9, $E7, $E9, $EA, $FB, $E5, $E3, $EC, $F6, {w}
  $F7, $ED, $FF, $D5, $2F, $7D, $A8);  // На утро - Старый код символа }: $DA но выбивает ошибку синтаксиса. Новый код $7D и тоже ошибка. Нужно разобраться!!!

var
  Instance: HWND;
  WindowClass: TWNDCLASS;
  FHandle: HWND;
  mesg: TMSG;
  noIconData: TNOTIFYICONDATA;
  HIcon1: HICON;
  WindowHandle, EditHandle: HWND;

function WindowProc(Hwn: HWND; msg: uint; wpr: WPARAM; lpr: LPARAM): LRESULT; stdcall;
var
  s: String;
  stClip: String;
  i,n: Integer;
begin
  Result := 0;
  case msg of
    WM_DESTROY:
    begin
      PostQuitMessage(0);
    end;

    WM_KEYDOWN:
    begin

    end;

    Ico_Message:
    begin
      case lpr of
        WM_LBUTTONDOWN:
        begin
          ShowWindow(FHandle, SW_SHOW);
          UpdateWindow(FHandle);
        end;
        WM_RBUTTONDOWN:
          ShowWindow(FHandle, SW_HIDE);
      end;
    end;

    WM_CLOSE:
    begin
      s := Utf8ToAnsi('Закрыть окно?');
      if MessageBox(FHandle, @s[1], 'Warning', MB_YESNO) = IDYES then
        DestroyWindow(FHandle)
      else
        ShowWindow(FHandle, SW_HIDE);
    end;

    WM_HOTKEY:
    begin
      if wpr = 1 then
      begin
        WindowHandle := GetForegroundWindow;
        EditHandle := GetTopWindow(WindowHandle);
        keybd_event(VK_CONTROL, 0,0,0);
        keybd_event(VK_CONTROL,0,KEYEVENTF_KEYUP,0);
        keybd_event(ord('C'),0,0,0);
        keybd_event(ord('C'),0,KEYEVENTF_KEYUP,0);
        keybd_event(ord('V'),0,0,0);
        keybd_event(ord('V'),0,KEYEVENTF_KEYUP,0);


        //PostMessage(EditHandle, WM_KEYDOWN, VK_CONTROL, $001D0001); медленный вариант
        //PostMessage(EditHandle, WM_KEYDOWN, ord('C'), $002E0001);   медленный вариант
        SendMessage(EditHandle, WM_COMMAND, $00010043, $00000000);

        stClip := Clipboard.AsText; //забрать из буффера в строку

        //Здесь продолжение цикла перебора констант символов для замены неправильно набранного текста
        //Большой блок логики
        //Перебор массива данных Англ раскладки для сравнение таблиц клавиатуры
        PostQuitMessage(0);
      end;
    end;

    else
      Result := DefWindowProc(hwn, msg, wpr, lpr);
  end;
end;

procedure CreateMyicon;
begin
  HIcon1 := LoadIcon(Instance, 'MAINICON');
  with noIconData do begin
    cbSize := SizeOf(TNOTIFYICONDATA);
    hWnd := FHandle; //Изначальный параметр wnd!
    uID := 0;
    UFlags := NIF_MESSAGE or NIF_ICON or NIF_TIP;
    SzTip := 'constray';
    hIcon := HIcon1;
    uCallbackMessage := Ico_Message;
  end;
  Shell_NotifyIconA(NIM_ADD, @noIconData);
end;

procedure DestroyMyicon;
begin
  ShellApi.Shell_NotifyIconA(NIM_DELETE, @noIconData);
end;

{$R *.res}

begin
  Instance := GetModuleHandle(nil);
  with WindowClass do
  begin
    style := CS_HREDRAW or CS_VREDRAW;
    lpfnWndProc := @WindowProc;
    hInstance := Instance;
    hbrBackground := COLOR_BTNFACE;
    lpszClassName := 'DX';
    hIcon := LoadIcon(hInstance, 'MAINICON');
    //hCursor := LoadIcon(0, IDI_HAND);
  end;

  RegisterClass(WindowClass);

  FHandle := CreateWindowEx(0, 'DX', 'Lang window', WS_OVERLAPPEDWINDOW, 5,5, 200, 200, 0,0,Instance, nil);
  RegisterHotKey(FHandle, 1, MOD_CONTROL or $4000, VK_F12);
  CreateMyicon;

  while (GetMessage(mesg, 0,0,0)) do
  begin
    TranslateMessage(mesg);
    DispatchMessage(mesg);
  end;
  DestroyMyicon;
end.



