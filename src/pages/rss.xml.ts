import rss from '@astrojs/rss';
import type { APIRoute } from 'astro';
import { getCollection } from 'astro:content';

export const GET: APIRoute = async (context) => {
  const posts = (await getCollection('blog', ({ data }) => !data.draft)).sort(
    (a, b) => b.data.pubDate.getTime() - a.data.pubDate.getTime(),
  );

  return rss({
    title: 'DefDev Blog',
    description: 'Practical posts on Kubernetes, cloud-native architecture, platform engineering, and open source projects built in public.',
    site: context.site ?? 'https://www.defdev.io',
    items: posts.map((post) => ({
      title: post.data.title,
      description: post.data.description,
      pubDate: post.data.pubDate,
      link: `/blog/${post.slug}`,
      content: post.body,
    })),
    customData: '<language>en-us</language>',
  });
};