unit Unit1;

interface

uses
	Windows, Messages, SysUtils, Forms, Classes,
	Graphics, Controls, Dialogs, StdCtrls, {Buttons,}
	ComCtrls, {ExtCtrls,} Registry, jpeg;

type
	TForm1 = class(TForm)
		Label1: TLabel;
		Label2: TLabel;
		Label3: TLabel;
		Label4: TLabel;
		Label5: TLabel;
		Label6: TLabel;
		Label7: TLabel;
		Edit1: TEdit;
		Edit2: TEdit;
		Edit3: TEdit;
		Edit4: TEdit;
		ProgressBar1: TProgressBar;
		OpenDialog1: TOpenDialog;
		SaveDialog1: TSaveDialog;
		procedure FormCreate(Sender: TObject);
		procedure Edit1Change(Sender: TObject);
		procedure FormDestroy(Sender: TObject);
		procedure FormPaint(Sender: TObject);
		procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
		procedure Label1MouseEnter(Sender: TObject);
		procedure Label1MouseLeave(Sender: TObject);
		procedure Label1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
		procedure Label1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
		procedure Label1Click(Sender: TObject);
		procedure Label2Click(Sender: TObject);
		procedure Label5Click(Sender: TObject);
		procedure Label6Click(Sender: TObject);
		procedure Label7Click(Sender: TObject);
	private
	{ Private declarations }
	public
	{ Public declarations }
	end;

var
	Form1: TForm1;
	Work: Boolean;
	bgFile: String = 'bg.jpg';
	bgPic: TPicture;

const
	Section: String = 'Software\Makc\Cus3';

	function Alert(Text: String; Caption: String; Flags: Integer): Integer;
	procedure Load;
	procedure Save;
	function FileToFile(FromF: String; FFStart, FFSize: Integer; ToF: String): Byte;
	procedure Check;
	procedure DrawBGImage;
	procedure DrawCaption;

implementation

{$R *.DFM}

function Alert(Text: String; Caption: String; Flags: Integer): Integer;
begin
	Result := Application.MessageBox(PChar(Text), PChar(Caption), Flags);
end;

procedure Load;
var
	i: TRegistryIniFile;
	s: String;
begin
	with Form1 do
	begin
		i := TRegistryIniFile.Create(Section);
		s := 'Parameters';
		Edit1.Text	:= i.ReadString(s, 'File 1', '');
		Edit2.Text	:= i.ReadString(s, 'File 2', '');
		Edit3.Text	:= IntToStr(i.ReadInteger(s, 'Pos 1', 0));
		Edit4.Text	:= IntToStr(i.ReadInteger(s, 'Pos 2', 0));
		s := 'Position';
		Top			:= i.ReadInteger(s, 'Top', ((Screen.Height - Height) div 2));
		Left		:= i.ReadInteger(s, 'Left', ((Screen.Width - Width) div 2));
		i.Free;
	end;
end;

procedure Save;
var
	i: TRegistryIniFile;
	s: String;
begin
	with Form1 do
	begin
		i := TRegistryIniFile.Create(Section);
		s := 'Parameters';
		i.WriteString(s, 'File 1', Edit1.Text);
		i.WriteString(s, 'File 2', Edit2.Text);
		i.WriteInteger(s, 'Pos 1', StrToInt(Edit3.Text));
		i.WriteInteger(s, 'Pos 2', StrToInt(Edit4.Text));
		s := 'Position';
		i.WriteInteger(s, 'Top', Top);
		i.WriteInteger(s, 'Left', Left);
		i.Free;
	end;
end;

function FileToFile(FromF: String; FFStart, FFSize: Integer; ToF: String): Byte;
var
	f1, f2: File;
	Buff: array [1..3000] of Char;
	BytesA, BytesO: Integer;
	BytesN, BytesR, BytesW: Integer;
	lp: Boolean;
begin
	Result := 1;
	BytesA := 0;
	BytesO := 0;
	BytesN := 0;
	BytesR := 0;
	BytesW := 0;
	with Form1 do
	begin
		lp := FileExists(FromF);
		if lp then
		begin
			with ProgressBar1 do
			begin
				Position := 0;
				Min := 0;
				Max := 0;
				Max := FFStart + FFSize;
				Min := FFStart;
				Position := FFStart;
			end;
			BytesN := SizeOf(Buff);
			TRY
				AssignFile(f1, FromF);
				AssignFile(f2, ToF);
				Reset(f1, 1);
				Rewrite(f2, 1);
				Seek(f1, FFStart);
				while lp do
				begin
					BytesO := FFSize - BytesA;
					if BytesO < BytesN then BytesN := BytesO;
					BlockRead(f1, Buff, BytesN, BytesR);
					BlockWrite(f2, Buff, BytesR, BytesW);
					BytesA := BytesA + BytesR;

					ProgressBar1.Position := FFStart + BytesA;
					Application.ProcessMessages;
					if ((BytesA = FFSize) or (BytesR <> BytesW) or (BytesR = 0)) then
					begin
						Result := 0;
						lp := False;
					end;
					if eof(f1) then
					begin
						lp := False;
						Result := 2;
					end;
					if not Work then
					begin
						lp := False;
						Result := 3;
					end;
				end;
			FINALLY
				CloseFile(f1);
				CloseFile(f2);
			END;
		end;
	end;
	if (BytesA = FFSize) and (BytesR = BytesW) then Result := 0;
end;

procedure Check;
begin
	with Form1 do
	begin
		if ((not FileExists(Edit1.Text))
		or (StrToInt(Edit4.Text) = 0)
		or (Edit2.Text ='')) then
		begin
			Label5.Enabled := False;
		end
		else
		begin
			Label5.Enabled := True;
		end;
	end;
end;

procedure DrawBGImage;
begin
	if Assigned(bgPic.Graphic) then Form1.Canvas.Draw(0, 0, bgPic.Graphic);
end;

procedure DrawCaption;
const
	m: String ='Makc © 2023';
var
	x, y: Byte;
begin
	x := 187;
	y := 2;
	with Form1.Canvas do begin
		Brush.Style := bsClear;
		Font.Color := clWhite;

		TextOut(x-1, y-1, m);
		TextOut(x, y-1, m);
		TextOut(x+1, y-1, m);

		TextOut(x-1, y, m);
		TextOut(x+1, y, m);

		TextOut(x-1, y+1, m);
		TextOut(x, y+1, m);
		TextOut(x+1, y+1, m);

		Font.Color := clBlack;
		TextOut(x, y, m);
	end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
	bgPic := TPicture.Create;
	if FileExists(bgFile) then
	begin
		bgPic.LoadFromFile(bgFile);
		with Form1 do begin
			Label1.Caption := '';
			Label2.Caption := '';
			Label3.Caption := '';
			Label4.Caption := '';
			Label5.Caption := '';
			Label6.Caption := '';
			Label7.Caption := '';
		end;
	end;
	Form1.Height	:= 93;
	Form1.Width		:= 441;
	Work := False;
	Load;
	Check;
end;

procedure TForm1.Edit1Change(Sender: TObject);
begin
	Edit3.Text := IntToStr(StrToIntDef(Edit3.Text, 0));
	Edit4.Text := IntToStr(StrToIntDef(Edit4.Text, 0));
	Check;
end;

procedure TForm1.FormDestroy(Sender: TObject);
begin
	Save;
	bgPic.Free;
end;

procedure TForm1.FormPaint(Sender: TObject);
begin
	DrawBGImage;
	DrawCaption;
end;

procedure TForm1.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
	if (Button = mbLeft) and ReleaseCapture then Form1.Perform(WM_SysCommand, 61458, 0);
end;

procedure TForm1.Label1MouseEnter(Sender: TObject);
var
	bTop, bLeft, bHeight, bWidth: Byte;
begin
	with Sender As(TLabel) do
	begin
		bTop := 0;
		bLeft := 0;
		bHeight := Height-1;
		bWidth := Width-1;
		with Canvas do
		begin
			Pen.Color := clActiveCaption;
			MoveTo(bWidth, bTop);
			LineTo(bLeft, bTop);
			LineTo(bLeft, bHeight);
			Pen.Color := clBackground;
			LineTo(bWidth, bHeight);
			LineTo(bWidth, bTop);
		end;
	end;
end;

procedure TForm1.Label1MouseLeave(Sender: TObject);
begin
	with Sender As(TLabel) do
	begin
		Repaint;
	end;
end;

procedure TForm1.Label1MouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
	bTop, bLeft, bHeight, bWidth: Byte;
begin
	with Sender As(TLabel) do
	begin
		bTop := 0;
		bLeft := 0;
		bHeight := Height-1;
		bWidth := Width-1;
		with Canvas do
		begin
			Pen.Color := clBackground;
			MoveTo(bWidth, bTop);
			LineTo(bLeft, bTop);
			LineTo(bLeft, bHeight);
			Pen.Color := clActiveCaption;
			LineTo(bWidth, bHeight);
			LineTo(bWidth, bTop);
		end;
	end;
end;

procedure TForm1.Label1MouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
	Label1MouseEnter(Sender);
end;

procedure TForm1.Label1Click(Sender: TObject);
begin
	Application.ProcessMessages;
	with OpenDialog1 do
	begin
		InitialDir := ExtractFilePath(Edit1.Text);
		if Execute then Edit1.Text := FileName;
	end;
end;

procedure TForm1.Label2Click(Sender: TObject);
begin
	Application.ProcessMessages;
	with SaveDialog1 do
	begin
		InitialDir := ExtractFilePath(Edit2.Text);
		if Execute then Edit2.Text := FileName;
	end;
end;

procedure TForm1.Label5Click(Sender: TObject);
var
	b: Byte;
begin
	Application.ProcessMessages;
	Work := not Work;
	if Work then
	begin
		b := FileToFile(Edit1.Text, StrToInt(Edit3.Text), StrToInt(Edit4.Text), Edit2.Text);
		if b = 0 then
		begin
			MessageBeep(mb_Ok);
		end
		else if  b = 1 then
		begin
			Alert('Внутренняя ошибка', 'Ошибка', mb_IconHand);
		end
		else if b = 2 then
		begin
			Alert('Достигнут конец файла', 'Информация', mb_IconInformation);
		end;
	end;
	Work := False;
end;

procedure TForm1.Label6Click(Sender: TObject);
begin
	Application.Minimize;
end;

procedure TForm1.Label7Click(Sender: TObject);
begin
	Application.Terminate;
end;

end.






