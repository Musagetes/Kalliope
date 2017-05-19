import Head from './head';
import Link from 'next/link';
import * as Links from './links.js';
const links = [
  { href: '/da/poets', label: 'Dansk' },
  { href: '/en/poets', label: 'Engelsk' },
].map(link => {
  link.key = `nav-link-${link.href}-${link.label}`;
  return link;
});

const Nav = props => {
  const { lang } = props;
  const _poetsURL = Links.poetsURL(lang);
  return (
    <nav>
      <ul>
        <ul>
          <li>
            <a href="/">Kalliope</a>
          </li>
          <li>
            <a href={_poetsURL}>Digtere</a>
          </li>
        </ul>
        <ul>
          {links.map(({ key, href, label }) => (
            <li key={key}>
              <a href={href}>{label}</a>
            </li>
          ))}
        </ul>
      </ul>

      <style jsx>{`
      :global(body) {
        margin: 0;
        font-family: -apple-system,BlinkMacSystemFont,Avenir Next,Avenir,Helvetica,sans-serif;
      }
      nav {
        text-align: left;
      }
      ul {
        display: flex;
        justify-content: space-between;
      }
      nav > ul {
        padding: 4px 0px;
      }
      li {
        display: flex;
        padding: 6px 16px;
      }
    `}</style>
    </nav>
  );
};
export default Nav;
