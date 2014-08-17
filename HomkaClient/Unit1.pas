unit Unit1;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, jpeg, ExtCtrls, ComCtrls,iniFiles;

type
  TForm1 = class(TForm)
    Memo1: TMemo;
    ScrollBox1: TScrollBox;
    Image1: TImage;
    ScrollBox2: TScrollBox;
    Image2: TImage;
    ComboBox1: TComboBox;
    ComboBox2: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
  private
    { Private declarations }
  public
  function SeochFilePapka(Dir:string):boolean;
  end;

const
  dirData = 'D:\Program Files (x86)\DAEMON Tools Lite\Lang\Homovoy\';
var
  Form1: TForm1;
  put:string;
implementation

{$R *.dfm}
function TForm1.SeochFilePapka(Dir:string):boolean;
var
  SR: TSearchRec;
  FindRes: Integer;
begin
  FindRes := FindFirst(Dir + '*.*', faAnyFile, SR);
  while FindRes = 0 do
  begin
    if {(sr.Name<>'.')or(sr.Name<>'..')}  length(sr.Name)>6
      then ComboBox1.Items.add(SR.Name) ;
   FindRes := FindNext(SR);
  end;
  SeochFilePapka:=true;
  FindClose(SR);
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
   put:='D:\Android Manager_MP_V6\Agent\';
   SeochFilePapka(dirData);
end;

procedure TForm1.ComboBox1Change(Sender: TObject);
begin
  memo1.text:='';
  IMAGE2.Picture.LoadFromFile(put+'tnt.jpg');
  try
    copyFile(Pchar(dirData+ComboBox1.items.strings[ComboBox1.itemindex]+'\1sDr.cfk'),Pchar(put+'begin.bmp'),true);
    IMAGE1.Picture.LoadFromFile(put+'begin.bmp');
    deleteFile(put+'begin.bmp');
  except
    IMAGE1.Picture.LoadFromFile(put+'tnt.jpg');
    showmessage('Файли не знайдені');
  end;
end;

procedure TForm1.ComboBox2Change(Sender: TObject);
var ini: TIniFile;
    fille,papka:string;
    i:integer;
begin
  try
    i:=ComboBox2.items.Count+1;
    ComboBox2.Items.Add(IntToStr(i));   
    IMAGE1.Picture.LoadFromFile(put+'tnt.jpg');
    IMAGE2.Picture.LoadFromFile(put+'tnt.jpg');
    papka:=ComboBox1.items.strings[ComboBox1.itemindex];
    fille:=ComboBox2.items.strings[ComboBox2.itemindex];
    copyFile(Pchar(dirData+papka+'\begin '+fille+'.cfk'),Pchar(put+'begin'+fille+'.bmp'),true);
    IMAGE1.Picture.LoadFromFile(put+'begin'+fille+'.bmp');
    deleteFile(put+'begin'+fille+'.bmp');
    copyFile(Pchar(dirData+papka+'\end '+fille+'.cfk'),Pchar(put+'end'+fille+'.bmp'),true);
    IMAGE2.Picture.LoadFromFile(put+'end'+fille+'.bmp');
    deleteFile(put+'end'+fille+'.bmp');
    ini := TIniFile.Create(dirData+papka+'\MyIni.ini');
    memo1.text:='Серійний номер='+ini.ReadString(fille,'Серійний номер','');
    memo1.lines.add('Час під'+''''+'єднання накопичувача='+ini.ReadString(fille,'Час під'+''''+'єднання накопичувача',''));
    memo1.lines.add('Файли та папки в каталозі на початку='+ini.ReadString(fille,'Файли та папки в каталозі на початку',''));
    memo1.lines.add('Файли та папки в каталозі на кінець='+ini.ReadString(fille,'Файли та папки в каталозі на кінець',''));
    memo1.lines.add('Час від'+''''+'єднання накопичувача='+ini.ReadString(fille,'Час від'+''''+'єднання накопичувача',''));
    memo1.lines.add('Файли та папки, які підготовлені до копіювання='+ini.ReadString(fille,'Файли та папки, які підготовлені до копіювання',''));
  except
    showmessage('Файли не знайдені');
  end;

end;

end.
