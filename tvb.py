import asyncio, aiohttp, tempfile, huggingface_hub, zhconv, bs4, os, sys, argparse, fake_useragent, itertools
parser = argparse.ArgumentParser()
parser.add_argument('huggingface')

huggingface_hub.login(parser.parse_args().huggingface) #https://huggingface.co/settings/tokens
unlink = []

async def main():
    async with aiohttp.ClientSession(headers={'user-agent':fake_useragent.UserAgent().chrome}) as client:
        async with client.get('https://www.tvbanywherena.com/cantonese/series/1372-ForensicHeroesIV') as program:
            for episode in itertools.islice(bs4.BeautifulSoup(await program.text(), 'lxml').find('div', attrs={'class':'episodeDiv'}).find_all('a'), 27, None):
                async with client.get(f'https://edge.api.brightcove.com/playback/v1/accounts/5324042807001/videos/{episode.get("href").split("/")[-1]}', headers={'accept':'application/json;pk=BCpkADawqM105amwEKXAkX7W_l4jcpUMMPNr331wjQzRwTMHyoZ_qxPNx8KG3SCWEylM62XxHZXjuFl2EzrVsCKAAOlBuMFX4KAu3BW3NCqhEobE5Vcxknb6TV_anuQZUp8wfI3zcyatmzYor7rx9opPSQ_71RkQmktElORv1l98AqgNbeYQlwWt6GoAMidUC3cR65WrWYBctr5lz6U_u-TGGWdO_JUIuHiMfxs2oygZNHWVUhl0R5qWlZaM32dkny102bhHDr8wzR24z1XH9yDlL93O58cBxi23o97WDluICmIr5Tn4fZ-qLrg8bRkpkhh5qCyjYcaiM5WQ332wyortFVEn7vN27r7imEMPVVbjlFSugd2XuRpPbvtezQfWmVd80BRpcvUDPLSdfDM4VhcpgGu-BXbXOSAk1vmlgMNfGGi19TJbZQiHyJY', 'origin':'https://www.tvbanywherena.com'}) as _:
                    json = await _.json()
                    async with client.get(json.get('sources')[0].get('src')) as m3u8:
                        with tempfile.NamedTemporaryFile(delete=False) as tmp:
                            sys.modules[__name__].unlink += tmp.name,
                            ffmpeg = await asyncio.create_subprocess_exec('ffmpeg', '-y', '-protocol_whitelist', 'http,https,file,tls,tcp,pipe', '-i', '-', '-f', 'mp4', tmp.name, stdin=asyncio.subprocess.PIPE)
                            await ffmpeg.communicate(await m3u8.content.read())
                            api = huggingface_hub.HfApi()
                            customFields = json.get('custom_fields')
                            programName = zhconv.convert(customFields.get('program_name'), 'zh-cn')
                            future = api.upload_file(path_or_fileobj=tmp.name, path_in_repo='/'.join(('cantonese', programName, customFields.get('beacon_episode_number').zfill(2) + '.mp4')), repo_id='chaowenguo/video', repo_type='model', run_as_future=True)
    return future

asyncio.run(main()).result()
for _ in unlink: os.unlink(_)
