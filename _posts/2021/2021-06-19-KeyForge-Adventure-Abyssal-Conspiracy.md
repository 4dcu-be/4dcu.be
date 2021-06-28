---
layout: post
title:  "Printing Abyssal Conspiracy"
byline: "the second KeyForge Adventure"
date:   2021-06-19 10:00:00
author: Sebastian Proost
categories: diy games programming
tags:	printing 3d-printing python keyforge
cover:  "/assets/posts/2021-06-19-KeyForge-Adventure-Abyssal-Conspiracy/abyssal_conspiracy_header.jpg"
thumbnail: "/assets/images/thumbnails/abyssal_conspiracy.jpg"
gallery_items:
  - image: "/assets/posts/2021-06-19-KeyForge-Adventure-Abyssal-Conspiracy/abyssal_conspiracy_header.jpg"
    gallery_image: "/assets/images/gallery/abyssal_conspiracy.jpg"
    description: "Abyssal Conspiracy cards printed in 2D with the tableau token in 3D."
---

Both KeyForge Adventures have been out for a while and as I've managed to defeat the Keyraken with all my decks it is
time to have a look at Abyssal Conspiracy. Preparing cards for printing is done using the same to steps as described
in [this post]({% post_url 2021/2021-04-29-Printing-The-Keyraken %}). While adding the bleed is exactly the same, extracting
the main cards didn't work. The reason was that the library [pdf2jpg] didn't support the newer image compression, 
JPEG2000, used in that PDF. So this issue has to be fixed first!

![KeyForge Adventure: Abyssal Conspiracy printed with 3D printed tableau token](/assets/posts/2021-06-19-KeyForge-Adventure-Abyssal-Conspiracy/abyssal_conspiracy_header.jpg)

The files you need to print this adventure can be found [here](https://www.fantasyflightgames.com/en/products/keyforge/)
in the *Support* section under *KeyForge Adventures Print-and-Play Materials*. All card files need to be processed,
the Seal Tableau we'll turn into a 3D printable token.

  * [The Card Pool](https://images-cdn.fantasyflightgames.com/filer_public/f7/24/f72436db-759f-4094-a1ac-5ef905013b8a/kf_adv_conspiracy_card_pool-compressed.pdf)
  * [Location Cards](https://images-cdn.fantasyflightgames.com/filer_public/ae/52/ae52772b-730e-4ba0-a3be-2191f085514f/kf_adv_conspiracy_locations_compressed.pdf)
  * [Seal Cards](https://images-cdn.fantasyflightgames.com/filer_public/61/90/6190d735-eac0-46a8-9b75-551665808693/kf_adv_conspiracy_seals.pdf)
  * [The Tide Card](https://images-cdn.fantasyflightgames.com/filer_public/7a/79/7a791a64-7c6a-4a0b-87fb-51cb85d0fbe7/kf_adv_conspiracy_tide.pdf)

  * [Card Backs](https://images-cdn.fantasyflightgames.com/filer_public/13/f6/13f62bc0-7321-4a0a-8ae8-6ddfd16e48fb/kf_adv_conspiracy_card_backs_compressed.pdf) 
    or use those from Reddit user [Dead-Sync](https://www.reddit.com/user/Dead-Sync) [here](https://www.reddit.com/r/KeyforgeGame/comments/ncy2r6/abyssal_conspiracy_individual_card_pngs_custom/)
    which already include a bleed and are ready to print

  * [The Seal Tableau](https://images-cdn.fantasyflightgames.com/filer_public/7d/62/7d625289-55bb-4db7-82a2-aeb92d8377d2/kf_adv_card_connector.pdf)

  * Tokens to track player positions. You can use anything, but there is a great option on Thingiverse [here](https://www.thingiverse.com/thing:4885866)

  * A copy of [the rules](https://images-cdn.fantasyflightgames.com/filer_public/aa/80/aa806171-5f17-4f78-b4a1-fee470deaf11/kf_adv_rulebook_id_compressed.pdf)

Only the file with the card pool uses
this new format, other files can be processed exactly as described in my [previous post]({% post_url 2021/2021-04-29-Printing-The-Keyraken %}).

## Extracting the cards images

As [pdf2jpg] didn't work, another package has to be used and [pdf2image] is up to the task! However, it does require
you to have [poppler] installed somewhere on your system. So make sure to pip install pdf2image and put a copy of
poppler somewhere on your system.

Paths to the input file and output are hard-coded, since this is a one-off script I think I'll get away with it. It is 
also the easiest way to share working code through a blog, just don't do this in serious projects. The ```output_path```
is created if needed. Using this library we need to load and export page by page. The loop over ```range(1, 44)```
takes care of this, but again, hard coded range here, so it will only work for this specific PDF.

```python
from pdf2image import convert_from_path
import pathlib

input_path = "./data/kf_adv_conspiracy_card_pool-compressed.pdf"
output_path = "./output/kf_adv_conspiracy_card_pool-compressed.blog/"

p = pathlib.Path(output_path)
p.mkdir(parents=True, exist_ok=True)

print(f"Converting {input_path}....")
for pn in range(1, 44):
    pages = convert_from_path(input_path, single_file=True, first_page=pn, poppler_path="D:\\poppler-21.03.0\\Library\\bin", dpi=1200)
    print(f"converting page {pn}")
    pages[0].save(str(p.joinpath(f"card_{pn:02}.jpg")), quality=95)

print("Done !")
```

pdf2image is a little under-documented, and I couldn't find a good way to process the file as a whole. So here we load
a single page, defining which page using ```first_page=pn```, and write it to disk as a .jpg file.

Once all 43 cards have been exported, the bleed area can be added using scripts from the 
[previous post]({% post_url 2021/2021-04-29-Printing-The-Keyraken %}) and done !

![Abyssal conspiracy printed and layed out to play](/assets/posts/2021-06-19-KeyForge-Adventure-Abyssal-Conspiracy/game_setup.jpg)

## Creating a 3D printable Seal Tableau token

With all code in place to get images printable through a service, there is only the Seal Tableau to do. A solid option
would be to print the PDF on [sticker paper apply a few layers of clear coat]({% post_url 2021/2021-06-14-Stickers %}), put 
the sticker on a piece of cardboard, and cut the shape out. 

However, I wanted to create a 3D printed one. The process used is essentially the same as to create a [lithophane] with
a 3D printer, but in reverse. While normally dark parts are thicker, creating the image when light
shines through the back, here the lightest parts need to be printed thickest.

![Creating a lithophane is very easy using this online tool](/assets/posts/2021-06-19-KeyForge-Adventure-Abyssal-Conspiracy/3dprocks_lithophane.png)

Converting the image to STL can be done online e.g. using [https://3dp.rocks/lithophane/](https://3dp.rocks/lithophane/).
Depending on the service you use you might need to invert the image (on 3dp.rocks this is not required). 
However, this will create a rectangular item, which needs to be cut into a pentagram. This can easily be done using
[MeshMixer], or (with a steeper learning curve) [Blender].

![Lithophane STL cut into pentagram, final tableau token is ready to print](/assets/posts/2021-06-19-KeyForge-Adventure-Abyssal-Conspiracy/meshmixer_token.png)

After printing the model, I sanded it, primed it and painted it with Vallejo metallic paints to make it look like an
old copper coin. The result is rather nice, do note I scaled the token down to a size that fits a deck box. You can 
adjust the model size settings in [https://3dp.rocks/lithophane/](https://3dp.rocks/lithophane/) to fit your needs.

![3D printed Tableau Seal finished](/assets/posts/2021-06-19-KeyForge-Adventure-Abyssal-Conspiracy/tableau_token.jpg)

As we are 3D printing we might as well print a set of Delver tokens, available [here](https://www.thingiverse.com/thing:4885866)
to keep track of players' positions. I printed 3 and painted them in the same style as my Seal Tableau token.

![3D printed Delver tokens to keep track of players' positions](/assets/posts/2021-06-19-KeyForge-Adventure-Abyssal-Conspiracy/delver_tokens.jpg)

## Conclusion

I'm all set to try the next KeyForge Adventure! Looking forward to playing this one!

[pdf2jpg]: https://github.com/pankajr141/pdf2jpg
[pdf2image]: https://pypi.org/project/pdf2image/
[poppler]: https://github.com/oschwartz10612/poppler-windows/releases/
[lithophane]: https://en.wikipedia.org/wiki/Lithophane
[MeshMixer]: https://www.meshmixer.com/
[Blender]: https://www.blender.org/
