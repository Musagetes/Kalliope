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
    const srcset = CommonData.availableImageWidths
      .map(width => {
        const filename = src.replace(/.jpg$/, `-w${width}.jpg`);
        return `${filename} ${width}w`;
      })
      .join(', ');
    const sizes = '(max-width: 700px) 250px, 48vw';
    return (
      <div className="sidebar-picture">
        <figure>
          <img src={src} srcSet={srcset} sizes={sizes} width="100%" />
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
