# Screenshot

Create a single image with a user-specified array of screenshots.

## Script

The `screenshot.sh` script uses multiple options to perform a series of concatenations and create a single [ImageMagick](https://github.com/ImageMagick/ImageMagick) command.  All options are required except `-f` and `-m`.  The breakdown of each option and its purpose is below.

| Option | Description                                                                   |   Type   |
|:------:|:------------------------------------------------------------------------------|:--------:|
|  `-f`  | font of header text, string name from installed fonts (Roboto.ttf by default) | optional |
|  `-l`  | layout of output image, integers in columns:rows format                       | required |
|  `-m`  | mode color of output image, string of Dark or Light (Light by default)        | optional |
|  `-o`  | output image, file name with path without spaces                              | required |
|  `-s`  | screenshot image, file name with optional path without spaces                 | required |
|  `-t`  | text of column header, string without spaces                                  | required |

Both the `-s` and `-t` options are meant to be used multiple times when running the script (i.e. one `-s` for each screenshot and one `-t` for each text label).  There is some basic error handling to ensure the number of screenshots and text labels input match the expected layout.

### Size
The script detects the dimensions of the first screenshot image and creates the output image based on that.  Therefore, it should work for any device size (i.e. phone or tablet) and any orientation (i.e. portrait or landscape).  The only caveat is that the screenshots must be the same size with the same dimensions.

### Order
The order of the screenshot arguments determines how they will be inserted into the output image.  The first screenshot image will be in the first column and first row.  The second screenshot image will be in the second column and first row if there is only one row or the first column and second row if there are multiple rows.  In other words, the screenshot images fill the first column before moving on to the next from left to right.  The text labels do the same, but there is only one row of headers. So, the text labels are not inserted anywhere except the first row from left to right.

### Font
A font can be specified with the `-f` option to use for the header text labels.  Use any typeface with the `.otf` or `.ttf` file is in the same directory as the `screenshot.sh` script.  Then, update the `FONT` constant in the script from `Roboto.ttf` to the preferred font file name.  Built-in fonts shown by the `magick identify -list font` command can also be used.

### Command
In the compiled command run at the end of the script, it uses the `magick` command, which means [ImageMagick](https://github.com/ImageMagick/ImageMagick) needs to be installed on the system.  [ImageMagick 7.0.9-2](https://github.com/ImageMagick/ImageMagick/releases/tag/7.0.9-2)(`7.0.9-2 Q16 x86_64 2019-10-31`) was used for releases [1.0.0](https://github.com/theck13/screenshot/releases/tag/1.0.0), [1.1.0](https://github.com/theck13/screenshot/releases/tag/1.1.0), and [1.2.0](https://github.com/theck13/screenshot/releases/tag/1.2.0).  [ImageMagick 7.1.1-47](https://github.com/ImageMagick/ImageMagick/releases/tag/7.1.1-47)(`7.1.1-47 Q16-HDRI x86_64 22763`} was used for releases [1.2.1](https://github.com/theck13/screenshot/releases/tag/1.2.1) and [1.2.2](https://github.com/theck13/screenshot/releases/tag/1.2.2).

## Sample

Here are a few example uses with explanations to help understand how to use `screenshot.sh`.

```bash
./screenshot.sh -l 2:1 -o output.png -s screenshot1.png -s screenshot2.png -t Text1 -t Text2
```

The command above will create the `output.png` file, which will have two columns and one row with the first column containing the “Text1” header with the `screenshot1.png` image and the second column containing the “Text2” header with the `screenshot2.png` image.  The headers will use the default Roboto font.  The color will be the default Light mode.  All files are in the same directory as `screenshot.sh`.  The `output.png` image is shown below.

<kbd>
    <img
        alt="Screenshot Script Output Image, Column 1 Containing Text1 Header with Screenshot1 Image and Column 2 Containing Text2 Header with Screenshot2 Image, Headers with Default Roboto Font, Color in Default Light Mode"
        src="https://github.com/user-attachments/assets/42154b2f-30b8-4ad5-84f3-5aa0e57f33f4"
    />
</kbd>

```bash
./screenshot.sh -m Dark -o publication_style_dark_light_times.png -l 2:3 -f "Times New Roman" -t "Publication Style [Dark]" -t "Publication Style [Light]" -s add_style_setting_publication_dark_01.png -s add_style_setting_publication_dark_02.png -s add_style_setting_publication_dark_03.png -s add_style_setting_publication_light_01.png -s add_style_setting_publication_light_02.png -s add_style_setting_publication_light_03.png
```

The command above will create the `publication_style_dark_light_times.png` file, which will have two columns and three rows with the first column containing the “Dark Theme” header with the `add_style_setting_publication_dark_01.png`, `add_style_setting_publication_dark_02.png`, and `add_style_setting_publication_dark_03.png` images and the second column containing the “Light Theme” header with the `add_style_setting_publication_light_01.png`, `add_style_setting_publication_light_02.png`, and `add_style_setting_publication_light_03.png` images.  The headers will use Times New Roman font.  The color will be the Dark mode.  All files are in the same directory as `screenshot.sh`.  The `publication_style_dark_light_times.png` image is shown below.

<kbd>
    <img
        alt="Screenshot Script Output Image, Column 1 Containing Dark Theme Header with Add Style Setting Publication Dark Images and Column 2 Containing Light Theme Header with Add Style Setting Publication Light Images, Headers with Times New Roman Font, Color in Dark Mode"
        src="https://github.com/user-attachments/assets/631d272b-496c-46de-bd2b-a5828d9a6b81"
    />
</kbd>

```bash
./screenshot.sh -m Dark -o /Users/Tyler/Documents/before_after_compare.png -l 3:6 -f Helvetica -t Before -t After -t Compare -s ~/Downloads/2339_text_field_background_after_dark_default.png -s ~/Downloads/2339_text_field_background_after_dark_disabled.png -s ~/Downloads/2339_text_field_background_after_dark_error.png -s ~/Downloads/2339_text_field_background_after_light_default.png -s ~/Downloads/2339_text_field_background_after_light_disabled.png -s ~/Downloads/2339_text_field_background_after_light_error.png -s ~/Downloads/2339_text_field_background_before_dark_default.png -s ~/Downloads/2339_text_field_background_before_dark_disabled.png -s ~/Downloads/2339_text_field_background_before_dark_error.png -s ~/Downloads/2339_text_field_background_before_light_default.png -s ~/Downloads/2339_text_field_background_before_light_disabled.png -s ~/Downloads/2339_text_field_background_before_light_error.png -s ~/Downloads/2339_text_field_background_compare_dark_default.png -s ~/Downloads/2339_text_field_background_compare_dark_disabled.png -s ~/Downloads/2339_text_field_background_compare_dark_error.png -s ~/Downloads/2339_text_field_background_compare_light_default.png -s ~/Downloads/2339_text_field_background_compare_light_disabled.png -s ~/Downloads/2339_text_field_background_compare_light_error.png 
```

The command above will create the `before_after_compare.png` file, which will have three columns and six rows with the first column containing the “Before” header with the `2339_text_field_background_before_dark_default.png`, `2339_text_field_background_before_dark_disabled.png`, `2339_text_field_background_before_dark_error.png`, `2339_text_field_background_before_light_default.png`, `2339_text_field_background_before_light_disabled.png`, and `2339_text_field_background_before_light_error.png` images, the second column containing the “After” header with the `2339_text_field_background_after_dark_default.png`, `2339_text_field_background_after_dark_disabled.png`, `2339_text_field_background_after_dark_error.png`, `2339_text_field_background_after_light_default.png`, `2339_text_field_background_after_light_disabled.png`, and `2339_text_field_background_after_light_error.png` images, and  the third column containing the “Compare” header with the `2339_text_field_background_compare_dark_default.png`, `2339_text_field_background_compare_dark_disabled.png`, `2339_text_field_background_compare_dark_error.png`, `2339_text_field_background_compare_light_default.png`, `2339_text_field_background_compare_light_disabled.png`, and `2339_text_field_background_compare_light_error.png` images.  The headers will use Helvetica font.  The color will be the Dark mode.  All input files are in the `~/Downloads/` directory and the output file in in the `/Users/Tyler/Documents/` directory.  The `before_after_compare.png` image is shown below.

<kbd>
    <img
        alt="Screenshot Script Output Image, Column 1 Containing Before Header with Text Field Background Before Images and Column 2 Containing After Header with Text Field Background After Images and Column 3 Containing Compare Header with Text Field Background Compare Images, Headers with Helvetic Font, Color in Dark Mode"
        src="https://github.com/user-attachments/assets/de448c27-d556-4795-bc16-082b5b69439d"
    />
</kbd>
