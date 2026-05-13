import streamlit as st
import requests
import re

# تنظیمات صفحه
st.set_page_config(page_title="Amazon Analyzer", layout="centered")
st.title("🔎 تحلیل‌گر محصولات آمازون")

# اطلاعات API شما از تصویر قبلی
RAPID_API_KEY = "f850411062msh9c1f1a42f138034p1889e6jsn608a2c1ea3a2"
RAPID_API_HOST = "basic-amazon-scraper.p.rapidapi.com"
AMAZON_SCRAPER_KEY = "f03399e151f471ce4a771f1se2f5yg3d"

def extract_keyword(url):
    match = re.search(r'k=([^&]+)', url)
    if match:
        return match.group(1).replace('+', ' ')
    return "products"

# ورودی کاربر
url_input = st.text_input("لینک آمازون را اینجا وارد کنید:")

if st.button("تحلیل و نمایش نتایج"):
    if url_input:
        with st.spinner('در حال دریافت داده‌ها از آمازون...'):
            keyword = extract_keyword(url_input)
            api_url = f"https://{RAPID_API_HOST}/search/{keyword}"
            
            headers = {
                "x-rapidapi-key": RAPID_API_KEY,
                "x-rapidapi-host": RAPID_API_HOST
            }
            params = {"api_key": AMAZON_SCRAPER_KEY}

            try:
                response = requests.get(api_url, headers=headers, params=params)
                data = response.json()
                products = data.get('results', [])

                if products:
                    valid_items = [p for p in products if p.get('price')]
                    
                    # محاسبات
                    cheapest = min(valid_items, key=lambda x: x['price'])
                    expensive = max(valid_items, key=lambda x: x['price'])
                    best = max(valid_items, key=lambda x: x.get('rating', 0))

                    # نمایش نتایج در ستون‌ها
                    col1, col2, col3 = st.columns(3)
                    
                    with col1:
                        st.success("💰 ارزان‌ترین")
                        st.write(f"**{cheapest['title'][:30]}...**")
                        st.metric("قیمت", f"${cheapest['price']}")
                    
                    with col2:
                        st.warning("💎 گران‌ترین")
                        st.write(f"**{expensive['title'][:30]}...**")
                        st.metric("قیمت", f"${expensive['price']}")
                    
                    with col3:
                        st.info("⭐ بهترین امتیاز")
                        st.write(f"**{best['title'][:30]}...**")
                        st.metric("امتیاز", f"{best.get('rating', 'N/A')}")
                else:
                    st.error("محصولی یافت نشد.")
            except Exception as e:
                st.error(f"خطا در اتصال: {e}")
    else:
        st.warning("لطفاً یک لینک معتبر وارد کنید.")
