requires 'perl', '5.008001';
requires 'File::Share';
requires 'Daiku';
requires 'Pod::Markdown', '2.001'; # need output_string()
requires 'Path::Maker';
requires 'File::pushd';

on 'test' => sub {
    requires 'Test::More', '0.98';
    requires 'File::Which';
};

