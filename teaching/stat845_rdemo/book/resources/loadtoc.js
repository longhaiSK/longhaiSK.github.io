
// loadmytoc.js — namespaced, self-contained TOC (right side, collapsible)
document.addEventListener('DOMContentLoaded', function () {
  // ---------- 1) Inject CSS ----------
  const css = `
  :root{
    --my-toc-width: 300px;
    --my-navbar-height: 56px;
  }
  /* Panel (right) */
  #my-toc-container {
    position: fixed;
    top: var(--my-navbar-height, 56px);
    right: 0;
    left: auto;
    width: var(--my-toc-width);
    max-height: calc(100vh - var(--my-navbar-height, 56px) - 24px);
    transform: translateX(calc(100% + 10px));
    overflow-y: auto;
    z-index: 999;
    background-color: #f9f9f9;
    border: 1px solid #ddd;
    border-right: none;
    border-radius: 8px 0 0 8px;
    padding: 14px 16px;
    font-family: Arial, sans-serif;
    box-sizing: border-box;
    box-shadow: -2px 0 5px rgba(0,0,0,0.1);
    transition: transform 0.35s ease-in-out;
  }
  #my-toc-container.my-active { transform: translateX(0); }

  body.my-toc-open { margin-right: var(--my-toc-width); transition: margin-right 0.35s ease-in-out; }

  /* Toggle button */
  #my-toc-toggle-button {
    position: fixed;
    top: var(--my-navbar-height, 56px);
    right: 0;
    left: auto;
    z-index: 1001;
    background-color: #e0e0e0;
    border: 1px solid #ccc;
    border-right: none;
    border-radius: 8px 0 0 8px;
    padding: 2px;
    cursor: pointer;
    display: inline-flex;
    align-items: center;
    justify-content: center;
    box-shadow: -2px 0 5px rgba(0,0,0,0.1);
    transition: background-color 0.25s ease-in-out, transform 0.35s ease-in-out;
  }
  #my-toc-toggle-button:hover { background-color: #d0d0d0; }
  #my-toc-toggle-button:focus-visible { outline: 2px solid royalblue; outline-offset: 2px; }
  #my-toc-toggle-button svg { width: 40px; height: 40px; color: royalblue; display: block; transition: transform 0.25s ease-in-out; }
  #my-toc-toggle-button[aria-expanded="true"] { transform: translateX(calc(-1 * var(--my-toc-width))); }
  #my-toc-toggle-button[aria-expanded="true"] svg { transform: scale(0.9) rotate(-180deg); }

  /* Title + list */
  .my-toc-title { margin: 0 0 10px 0; font-size: 1.05em; font-weight: 700; color: #000; }
  .my-toc-list, .my-toc-sublist { margin: 0; padding-left: 20px; }
  .my-toc-list { list-style-type: disc; }
  .my-toc-sublist { list-style-type: circle; margin-top: 4px; }
  .my-toc-link { text-decoration: none; color: royalblue; display: block; padding: 4px 0; font-size: 1em; }
  .my-toc-link:hover, .my-toc-link:focus { text-decoration: underline; }
  .my-toc-link:focus-visible { outline: 2px solid royalblue; outline-offset: 2px; }

  .my-toc-up-link { display: inline-flex; align-items: center; gap: 6px; margin-bottom: 8px; color: inherit; text-decoration: none; }
  .my-toc-up-link.icon-only svg { width: 22px; height: 22px; }
  .my-toc-up-link.my-disabled { opacity: 0.4; pointer-events: none; }

  /* Collapsible */
  .my-toc-item { position: relative; }
  .my-toc-item.my-has-children { list-style-type: none; padding-left: 0; }
  .my-toc-row { display: flex; align-items: center; gap: 6px; }
  .my-toc-caret-btn {
    appearance: none; background: none; border: none; padding: 2px; margin: 0;
    cursor: pointer; line-height: 1; display: inline-flex; align-items: center; justify-content: center; border-radius: 4px;
  }
  .my-toc-caret-btn:hover { background: rgba(0,0,0,0.05); }
  .my-toc-caret-btn:focus-visible { outline: 2px solid royalblue; outline-offset: 2px; }
  .my-toc-caret { width: 1em; height: 1em; transition: transform 0.2s ease; }
  .my-toc-item.my-has-children:not(.my-is-open) > .my-toc-row .my-toc-caret { transform: rotate(-90deg); }
  .my-toc-item.my-has-children:not(.my-is-open) > .my-toc-sublist { display: none; }
  .my-toc-item.my-has-children.my-is-open > .my-toc-row > .my-toc-link { font-weight: 600; }

  @media (max-width: 800px) {
    body.my-toc-open { margin-right: 0; }
    #my-toc-toggle-button[aria-expanded="true"] { transform: translateX(0); }
    #my-toc-container { max-width: min(85vw, var(--my-toc-width)); width: min(85vw, var(--my-toc-width)); }
  }

  @media (prefers-color-scheme: dark) {
    #my-toc-container { background-color: #1f1f1f; border-color: #333; box-shadow: -2px 0 6px rgba(0,0,0,0.6); }
    #my-toc-toggle-button { background-color: #2a2a2a; border-color: #3a3a3a; }
    #my-toc-toggle-button:hover { background-color: #333; }
    .my-toc-title { color: #fff; }
    .my-toc-link { color: #9ab6ff; }
    .my-toc-caret-btn:hover { background: rgba(255,255,255,0.06); }
  }

  @media (prefers-reduced-motion: reduce) {
    #my-toc-container, #my-toc-toggle-button, body.my-toc-open { transition: none !important; }
  }

  @media print {
    #my-toc-container, #my-toc-toggle-button { display: none !important; }
  }`;

  const style = document.createElement('style');
  style.textContent = css;
  document.head.appendChild(style);

  // ---------- 2) Build container ----------
  const headings = Array.from(document.querySelectorAll('h1,h2,h3,h4,h5,h6'))
    .filter(h => !h.closest('#my-toc-container') && !h.closest('.my-no-toc'));
  if (headings.length === 0) return;

  const toc = document.createElement('nav');
  toc.id = 'my-toc-container';

  const toggle = document.createElement('button');
  toggle.id = 'my-toc-toggle-button';
  toggle.type = 'button';
  toggle.setAttribute('aria-expanded', 'false');
  toggle.innerHTML = `
    <svg viewBox="0 0 24 24"><path d="M8.59 16.59L13.17 12 8.59 7.41 10 6l6 6-6 6z"/></svg>`;

  // Up link
  function getParentDir(p){let path=p;if(path.endsWith('/index.html'))path=path.slice(0,-10);
    if(!path.endsWith('/'))path=path.slice(0,path.lastIndexOf('/')+1);
    const cut=path.slice(0,-1).lastIndexOf('/');return cut<=0?'/':path.substring(0,cut+1);}
  const parent=getParentDir(location.pathname);
  const atRoot=location.pathname==='/'||location.pathname==='/index.html';
  const up=document.createElement('a');
  up.classList.add('my-toc-up-link','icon-only');
  if(atRoot){up.classList.add('my-disabled');} else {up.href=parent;}
  up.innerHTML=`<svg viewBox="0 0 24 24" stroke="currentColor" fill="none" stroke-width="2.5">
  <polyline points="18 14 12 8 6 14"/><polyline points="18 18 12 12 6 18"/></svg>`;
  toc.appendChild(up);

  const title=document.createElement('h3');
  title.textContent='Table of Contents';
  title.className='my-toc-title';
  toc.appendChild(title);

  const list=document.createElement('ul');
  list.className='my-toc-list';
  const stack=[list];
  headings.forEach((h,i)=>{
    const li=document.createElement('li');
    li.className='my-toc-item';
    const a=document.createElement('a');
    a.className='my-toc-link';
    if(!h.id)h.id='my-toc-heading-'+i;
    a.href='#'+h.id; a.textContent=h.textContent.trim();
    const level=parseInt(h.tagName.substring(1));
    if(i>0){
      const prev=parseInt(headings[i-1].tagName.substring(1));
      if(level>prev){
        const parentLi=stack.at(-1).lastElementChild;
        if(parentLi){const sub=document.createElement('ul');
          sub.className='my-toc-list my-toc-sublist'; parentLi.appendChild(sub); stack.push(sub);}
      }else if(level<prev){
        for(let j=0;j<(prev-level)&&stack.length>1;j++)stack.pop();
      }
    }
    const row=document.createElement('div'); row.className='my-toc-row'; row.appendChild(a);
    li.appendChild(row); stack.at(-1).appendChild(li);
  });
  toc.appendChild(list);
  document.body.appendChild(toc);
  document.body.appendChild(toggle);

  // ---------- 3) Collapsible ----------
  let uid=0; const nextId=p=>p+(++uid);
  toc.querySelectorAll('li').forEach(li=>{
    const sub=li.querySelector(':scope > .my-toc-sublist');
    const link=li.querySelector(':scope > .my-toc-row > .my-toc-link');
    if(!sub||!link)return;
    li.classList.add('my-has-children');
    if(!sub.id)sub.id=nextId('my-sub-');
    const btn=document.createElement('button');
    btn.className='my-toc-caret-btn'; btn.type='button';
    btn.setAttribute('aria-controls',sub.id); btn.setAttribute('aria-expanded','false');
    btn.innerHTML=`<svg class="my-toc-caret" viewBox="0 0 24 24"><path d="M7.41 8.59 12 13.17l4.59-4.58L18 10l-6 6-6-6z"/></svg>`;
    li.querySelector(':scope > .my-toc-row').insertBefore(btn,link);
    const toggleSub=()=>{const open=li.classList.toggle('my-is-open');
      btn.setAttribute('aria-expanded',String(open));};
    btn.addEventListener('click',toggleSub);
    btn.addEventListener('keydown',e=>{
      if(e.key==='ArrowRight'&&btn.getAttribute('aria-expanded')==='false'){e.preventDefault();toggleSub();}
      if(e.key==='ArrowLeft'&&btn.getAttribute('aria-expanded')==='true'){e.preventDefault();toggleSub();}
    });
    if(li.parentElement.classList.contains('my-toc-list')){li.classList.add('my-is-open');btn.setAttribute('aria-expanded','true');}
  });

  // ---------- 4) Toggle panel ----------
  const setExpanded=exp=>{
    toggle.setAttribute('aria-expanded',String(exp));
    toc.classList.toggle('my-active',exp);
    document.body.classList.toggle('my-toc-open',exp);
  };
  toggle.addEventListener('click',()=>{
    const exp=toggle.getAttribute('aria-expanded')==='true';
    setExpanded(!exp);
  });
  document.addEventListener('click',e=>{
    if(!toggle||!toc)return;
    const exp=toggle.getAttribute('aria-expanded')==='true';
    if(!exp)return;
    if(!toc.contains(e.target)&&!toggle.contains(e.target))setExpanded(false);
  });

  // ---------- 5) Smooth scroll ----------
  toc.querySelectorAll('.my-toc-link[href^="#"]').forEach(a=>{
    a.addEventListener('click',e=>{
      const id=a.getAttribute('href').substring(1);
      const t=document.getElementById(id); if(!t)return;
      e.preventDefault(); t.scrollIntoView({behavior:'smooth',block:'start'});
    });
  });

  // ---------- 6) Navbar height ----------
  requestAnimationFrame(()=>{
    const nav=document.querySelector('.responsive-nav,.navbar,header.navbar,.quarto-navbar,nav.navbar');
    const h=Math.ceil((nav&&nav.getBoundingClientRect().height)||56);
    document.documentElement.style.setProperty('--my-navbar-height',h+'px');
  });
});

