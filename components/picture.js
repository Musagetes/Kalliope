// @flow
import React from 'react';
import type { PictureItem, Lang } from '../pages/helpers/types.js';
import TextContent from './textcontent.js';
import CommonData from '../pages/helpers/commondata.js';

export default class Picture extends React.Component {
  props: {
    picture: PictureItem,
    srcPrefix?: string,
    lang: Lang,
  };
  render() {
    const { picture, lang, srcPrefix } = this.props;

    const src = (srcPrefix || '') + '/' + picture.src;
    const sizes = '(max-width: 700px) 250px, 48vw';
    let srcsets = {};
    const sources = CommonData.availableImageFormats.map(ext => {
      const srcset = CommonData.availableImageWidths
        .map(width => {
          const filename = src.replace(/.jpg$/, `-w${width}.${ext}`);
          return `${filename} ${width}w`;
        })
        .join(', ');
      srcsets[ext] = srcset;
      const type = ext !== 'jpg' ? `image/${ext}` : '';
      return <source key={ext} type={type} srcSet={srcset} sizes={sizes} />;
    });
    // Nedenstående <img> burde ikke have setSet og sizes sat, men Safari virker
    // ikke uden. //  srcSet={srcsets['jpg']} sizes={sizes}
    return (
      <div className="sidebar-picture">
        <figure>
          <picture>
            {sources}
            <img src={src} width="100%" />
          </picture>
          <figcaption>
            <TextContent contentHtml={picture.content_html} lang={lang} />
          </figcaption>
        </figure>
        <style jsx>{`
          div.sidebar-picture {
            margin-bottom: 30px;
          }
          figure {
            margin: 0;
          }
          figcaption {
            margin-top: 8px;
            font-size: 0.8em;
          }
          img {
            border: 0;
            box-shadow: 4px 4px 12px #888;
          }
          @media print {
            figure {
              display: none;
            }
          }
        `}</style>
      </div>
    );
  }
}
