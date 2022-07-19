exports.handler = async (event: any, context: any): Promise<any> => {
    try {
        console.log(JSON.stringify(event));

        return JSON.stringify(event)
    } catch (e) {
        console.error(e);
        return JSON.stringify({message: e.message})
    }
};
